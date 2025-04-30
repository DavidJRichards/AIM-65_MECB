#! /bin/sh
#   python ./patch.py build/basic.rom cf71:11=00 cf73:02=04
#	python ./patch.py build/forth.rom wb00A:0300=0400 wB028:0300=0400 wC295:0300=0400 wb01C:030B=040B wb01A:0300=0400


python ./patch.py AH5050.BIN wD57D:A000=A4B0 wd583:a008=a4b8 wd591:a001=a4b1 wd594:a003=a4b3 wd599:a003=a4b3 wd59e:a002=a4b2 wd5a3:a00c=a4bc wd725:a00d=a4bd wd72d:a000=a4b0 wd732:a00c=a4bc wd737:a00c=a4bc wdb14:a001=a4b1 wdb17:a001=a4b1 wdb33:a001=a4b1 wdb3a:a001=a4b1 wdb44:a009=a4b9 wdb47:a00d=a4bd wdb69:a001=a4b1 wdb6e:a001=a4b1 

python ./patch.py AH5050.BIN  wdb8f:a001=a4b1 wdb94:a001=a4b1 wdbd6:a009=a4b9 wdbdc:a00d=a4bd wdc09:a001=a4b1 wdc0c:a001=a4b1 wdc3c:a001=a4b1 wdc41:a001=a4b1 wdc45:a001=a4b1 wdc4a:a001=a4b1 wdc4e:a001=a4b1 wdc53:a001=a4b1 wdc57:a001=a4b1 wdc5c:a001=a4b1 wdc60:a001=a4b1 wdc63:a001=a4b1 

python ./patch.py AH5050.BIN wd776:a480=a4e0 wd779:a482=a4e2 wd79a:a800=a4c0
