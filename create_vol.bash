#!/bin/bash



minimum=110
pv=`pvs|grep XSU-VG1  |awk '{print $6}'|cut -d '.' -f1`
	if [ $pv -lt $minimum ];then
	 	echo "The PVS free size is over $minimum"
		exit 0
	else
		echo "size is under $minimumsize bytes" >> /tmp/pvcreate.log
		
	fi

for volumexfs in `cat /create_vol/1.txt`;do
LOG=/tmp/pvcreate.log
        filesystem=`echo $volumexfs | awk -F, '{print $1}'`
        vol=`echo $volumexfs | awk -F, '{print $1}'|cut -f3 -d/`
        size=`echo $volumexfs | awk -F, '{print $2}'`
	
		ls $filesystem >> $LOG 2>&1
		if [ $? -eq 0 ];then
		echo "The filesystem ${filesystem} already exists, Please remove"
			exit 0
		else
        echo "Creation Filesystems=${filesystem}"
        echo "Creation Filesystems=${filesystem}" >> $LOG 2>&1
	sleep 2
                mkdir -p $filesystem
        	fi

        /usr/sbin/lvs |grep -q ${vol}
        if [ $? -eq 0 ];then
                echo "These lvms ${vol} already exists, Please remove"
		sleep 2
		exit 0
                echo "Creation Volume=${vol} Size=${size}"
		sleep 2
		
		else

                /usr/bin/ssm -f create -s $size -n $vol --fstype xfs -p XSU-VG1 << EOF
y
EOF
		sleep 5

                echo "Checking XSU-VG1 in /etc/fstab"
                cat /etc/fstab|grep -q ${vol}

                if [ $? -eq 0 ];then
			echo "These volumes ${vol} already exists, Please remove"
		exit 0
		else
                        echo "/dev/XSU-VG1/$vol    $filesystem         xfs defaults 0 0" >> /etc/fstab
		fi
                        echo "Mount all filesystems" >> $LOG 2>&1
			echo "Checking filesystems are mount" >> $LOG 2>&1
			mount |grep -q ${filesystem}
		if [ $? -ne 0 ];then
                        /usr/bin/mount -a
                fi
                cat /etc/exports |grep -q ${filesystem}

                if [ $? -ne 0 ];then
                echo "These filesystem ${filesystem} already exists, Please remove"
                        echo  "$filesystem         *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
                        echo "Exportfs all filesystems"
                        /usr/sbin/exportfs -a; /usr/sbin/exportfs -r
                fi
        fi
done
