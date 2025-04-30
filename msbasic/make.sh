if [ ! -d tmp ]; then
	mkdir tmp
fi

#for i in osi aim65 eater mecb djrm; do
for i in mecb; do

echo $i
ca65 -D $i msbasic.s -l tmp/$i.lst -o tmp/$i.o &&
ld65 -C $i.cfg tmp/$i.o -o tmp/$i.bin -Ln tmp/$i.lbl

done

