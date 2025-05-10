if [ ! -d tmp ]; then
	mkdir tmp
fi

#for i in osi aim65 eater mecb djrm; do
for i in mecb; do

echo $i
ca65 -D $i msbasic.s -l out/$i.lst -o out/$i.o &&
ld65 -C $i.cfg out/$i.o -o out/$i.bin -Ln out/$i.lbl
sort -k2 < out/$i.lbl >out/$i-sort.lbl
done

