@ECHO OFF
cd ..\System

REM Assemble the CP/M system into a binary image
REM Then move to outputs folder

REM Floppy kernel
..\Build\zasm config\config_fdc.asm -u -w -b cpm22.bin
move cpm22.bin bin\cpm22_fdc.bin >NUL
move config\*.lst ..\Output\Listings >NUL

REM NDSK kernel
..\Build\zasm config\config_ndsk.asm -u -w -b cpm22.bin
move cpm22.bin ..\Output\NDSK_CPM22.SYS >NUL
move config\*.lst ..\Output\Listings >NUL

REM NDSK hybrid kernel
..\Build\zasm config\config_ndsk_hybrid.asm -u -w -b cpm22.bin
move cpm22.bin ..\Output\NDSK_HYBRID_CPM22.SYS >NUL
move config\*.lst ..\Output\Listings >NUL

REM NFS kernel
..\Build\zasm config\config_nfs.asm -u -w -b cpm22.bin
move cpm22.bin ..\Output\NFS_CPM22.SYS >NUL
move config\*.lst ..\Output\Listings >NUL



REM Move resource into outputs
copy res\licca_font.bin ..\Output\FONT.GRB >NUL

REM Assemble the boot programs
..\Build\zasm boot\boot_fdc.asm -u -w -b boot_fdc.bin
move boot_fdc.bin bin >NUL
move boot\boot_fdc.lst ..\Output\Listings >NUL

..\Build\zasm boot\boot_ndsk.asm -u -w -b boot_ndsk.bin
copy boot_ndsk.bin ..\Output\NDSK_BOOT.nabu >NUL
move boot_ndsk.bin bin >NUL
move boot\boot_ndsk.lst ..\Output\Listings >NUL

..\Build\zasm boot\boot_ndsk_hybrid.asm -u -w -b boot_ndsk_hybrid.bin
copy boot_ndsk_hybrid.bin ..\Output\NDSK_HYBRID_BOOT.nabu >NUL
move boot_ndsk_hybrid.bin bin >NUL
move boot\boot_ndsk_hybrid.lst ..\Output\Listings >NUL

..\Build\zasm boot\boot_nfs.asm -u -w -b boot_nfs.bin
copy boot_nfs.bin ..\Output\NFS_BOOT.nabu >NUL
move boot_nfs.bin bin >NUL
move boot\boot_nfs.lst ..\Output\Listings >NUL


REM Build Ishkur-specific applications
cd ..\Applications
..\Build\zasm init.asm -u -w -b init.com
move init.com ..\Directory >NUL
move init.lst ..\Output\Listings >NUL
..\Build\zasm futil.asm -u -w -b futil.com
move futil.com ..\Directory >NUL
move futil.lst ..\Output\Listings >NUL

REM Assemble the disk image
cd ..\Build\cpmtools
.\mkfs.cpm -f osborne1 -b ..\..\System\bin\boot_fdc.bin -b ..\..\System\res\licca_font.bin -b ..\..\System\bin\cpm22_fdc.bin ishkur_fdc_ssdd.img
.\mkfs.cpm -f osborne1 ishkur_fdc_ssdd_empty.img
move ishkur_fdc_ssdd.img ..\..\Output >NUL
move ishkur_fdc_ssdd_empty.img ..\..\Output >NUL
.\mkfs.cpm -f nshd8 NDSK_DEFAULT.IMG
move NDSK_DEFAULT.IMG ..\..\Output >NUL

REM This loop is needed because winblows sucks
for %%f in (..\..\Directory\*) do (
	copy %%f %%~nf%%~xf >NUL
	echo Writing %%~nf%%~xf to image
	cpmcp -f osborne1 ..\..\Output\ishkur_fdc_ssdd.img %%~nf%%~xf 0:
	cpmcp -f nshd8 ..\..\Output\NDSK_DEFAULT.IMG %%~nf%%~xf 0:
	del %%~nf%%~xf
)

REM Resize the file
REM If only I had to `dd` command...
cd ..\..\Output
python ..\Build\e5pad.py ishkur_fdc_ssdd.img 204800
python ..\Build\e5pad.py ishkur_fdc_ssdd_empty.img 204800
python ..\Build\e5pad.py NDSK_DEFAULT.IMG 8388608