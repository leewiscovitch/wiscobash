we'll be testing using `cloudbase-init` to make windows virtual tempaltes that can be easily deployed using tech familiar to `cloud-base`

trying first with `win25x64` running off a fresh install, at the first screen where it asks for a password press `CTRL+SHIFT+F3` to edit auditing mode.

there you'll want to make sure leave up the `sysrep` window while working, as once you close it things start to happen! so keep it open and do the following:

* update windows fully
* install virtio drivers fully
  * don't forget guest agent

>made a snapshot, as at this point it gets messy!

* add a virtual serial port listening on port `0`
* install `cloudbase-init` client
  * username: tech
    * use meta-data for password
      * think that means either cloud-base or terraform will provide the eventual password for that user...which is good, but needs to be tested
  * user's local groups: Administrators
  * serial port for logging: COM1
  * leave last option about LocalSystem disabled (for now)
  
so when it's done it give you a chance to run the final systep step and then shutdown...we'll try that first and create a snapshot to test further

well, first potential fuckup...had the audtir mode instance up and repairing to see if we can re-run the steps without haveing to start over

well, that didn't work...so repeat but make sure the initial sysprep is closed!!!

ok, did that and made a snapshot, added a cloud-init drive and configured username, password and static ip

in theory when it turns on it should be good go to! if not rollback to previous snapshot and try again

it reboots a ton, so just kick back and relax

well first gui login it says the user tech needs to reset their password at first login...saw a lot show up in the serial debug

it did properly enable to the guest agent and ip address...I think, need to review what it was before

but after logging in cloudbase-init did a lot more!

and then it even reboots!

after the reboot, the static was fine...But now that I used the same password not sure if that part worked...plus we want to skip that whole set passwrd bs (and even the login to just wait for a reboot)

also just noticed I think the password change was for default Administrator account. there was also a `tech` account like we set during the password, but the `meta-date` password did not work

so at this point it would be cool to:
* skip the administrator part and logging in
* get the `tech` username and password working

going to try this way next:

https://xen-orchestra.com/blog/windows-templates-with-cloudbase-init-step-by-step-guide-best-practices/

you do have to add the `metadata_services=cloudbaseinit.metadata.services.nocloudservice.NoCloudConfigDriveService` to one of the files at the the end...the other file has it so replace it

ok made a snapshot, will try with proxmox cloud-int featues and see if any better than the last

ehh...still asked for administrator passed (But that might be by design the more I think about it) but it didn't seem to pickup the second/last part after I logged as administrator...waited 5+ minutes so far, will wait some more just in case

wonder if it could be the format of the cloud-base img, and also it was scanning and picked up the virtio iso...going to play around and retry

I don't think I'm setting the proxmox cloud-init stuff right...or, it's not supported or news some random tweak...off to google!

https://docs-next.bennetg.de/products/proxmox-cp/miscellaneous/windows-cloudbase-init

so does look like proxmox has some issues...

one of the things I think that is an issue is the base image...I think we should have skipped going straight into editor mode and set the Administrator password during OOBE. Then when installing cloudbase-init we can change the username to Administrator and disable the meta data for password. That should result in there being only one account at the end, with the sane password set during OOBE.

then make sure before running sysrep stage you setup cloudbase-init and Unattended.xml that it won't require password reset or change the account at all

Would still like to know how to do this with password changing support...but that might be terraform, and I'm tired for now