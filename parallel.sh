for el in $(ls -d $1/*/)
do
	echo $el
	git -C $el fetch -v &
	echo
done

wait
echo "All done"
