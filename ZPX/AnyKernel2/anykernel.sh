#!/sbin/sh

# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# EDIFY properties
kernel.string=rifle007 @xda
do.devicecheck=0
do.initd=1
do.modules=0
do.cleanup=1
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=

# shell variables
#leave blank for automatic search boot block
#block=
#is_slot_device=0;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel permissions
# set permissions for included ramdisk files
mount /system;
mount -o remount,rw /system;
chmod -R 755 $ramdisk
cp -rpf $patch/init.d /system/etc
cp -rpf $patch/cron.d /system/etc
cp -rpf $patch/thermal-engine.conf /system/etc/thermal-engine.conf
chmod -R 644 /system/etc/thermal-engine.conf
chmod -R 755 /system/etc/init.d
chmod -R 755 /system/etc/cron.d
rm /system/etc/init.d/99zpx_zram
#mv /system/bin/vm_bms /system/bin/vm_bms.bak
#chmod 644 $ramdisk/sbin/media_profiles.xml


## AnyKernel install
find_boot;
dump_boot;

# begin ramdisk changes


#change min freq
#big cluster
backup_file init.qcom.power.rc;
replace_line init.qcom.power.rc "write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq" "    write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq 400000";
#little cluster
replace_line init.qcom.power.rc "write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq" "    write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq 400000";
replace_line init.qcom.power.rc "setprop ro.min_freq_0" "    setprop ro.min_freq_0 400000";
replace_line init.qcom.power.rc "setprop ro.min_freq_4" "    setprop ro.min_freq_4 400000";

#change scalling
replace_line init.qcom.power.rc "write /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay" '    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay "20000 1113600:40000"';
replace_line init.qcom.power.rc "write /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay" '    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay "20000 800000:40000"';

replace_line init.qcom.power.rc "write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads" '    write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads "1 800000:85 960000:90 1113600:95"';
replace_line init.qcom.power.rc "write /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads" '    write /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads "1 800000:90"';

replace_line init.qcom.power.rc "setprop sys.io.scheduler" '    setprop sys.io.scheduler "bfq"';


## init.rc
#backup_file init.rc;
#replace_string init.rc "cpuctl cpu,timer_slack" "mount cgroup none /dev/cpuctl cpu" "mount cgroup none /dev/cpuctl cpu,timer_slack";
#append_file init.rc "run-parts" init;

## init.tuna.rc
#backup_file init.tuna.rc;
#insert_line init.tuna.rc "nodiratime barrier=0" after "mount_all /fstab.tuna" "\tmount ext4 /dev/block/platform/omap/omap_hsmmc.0/by-name/userdata /data remount nosuid nodev noatime nodiratime barrier=0";
#append_file init.tuna.rc "dvbootscript" init.tuna;

## init.superuser.rc
#if [ -f init.superuser.rc ]; then
#  backup_file init.superuser.rc;
#  replace_string init.superuser.rc "Superuser su_daemon" "# su daemon" "\n# Superuser su_daemon";
#  prepend_file init.superuser.rc "SuperSU daemonsu" init.superuser;
#else
#  replace_file init.superuser.rc 750 init.superuser.rc;
#  insert_line init.rc "init.superuser.rc" after "on post-fs-data" "    #import /init.superuser.rc";
#fi;

## insert extra init file init.mk.rc , init.aicp.rc , init.cm.rc
#backup_file init.rc
#insert_line init.rc "init.mk.rc" after "extra init file" "import /init.mk.rc";
#insert_line init.rc "init.aicp.rc" after "extra init file" "import /init.aicp.rc";
#insert_line init.rc "init.cm.rc" after "extra init file" "import /init.cm.rc";

## fstab.tuna
#backup_file fstab.tuna;
#patch_fstab fstab.tuna /system ext4 options "nodiratime,barrier=0" "nodev,noatime,nodiratime,barrier=0,data=writeback,noauto_da_alloc,discard";
#patch_fstab fstab.tuna /cache ext4 options "barrier=0,nomblk_io_submit" "nosuid,nodev,noatime,nodiratime,errors=panic,barrier=0,nomblk_io_submit,data=writeback,noauto_da_alloc";
#patch_fstab fstab.tuna /data ext4 options "nomblk_io_submit,data=writeback" "nosuid,nodev,noatime,errors=panic,nomblk_io_submit,data=writeback,noauto_da_alloc";
#append_file fstab.tuna "usbdisk" fstab;

# Set permissive on boot - but only if not already permissive
cmdfile=`ls $split_img/*-cmdline`;
cmdtmp=`cat $cmdfile`;
case "$cmdtmp" in
  *selinux=permissive*) ;;
  *) rm $cmdfile; echo "androidboot.selinux=permissive $cmdtmp" > $cmdfile;;
esac;

## end ramdisk changes

write_boot;

## end install
