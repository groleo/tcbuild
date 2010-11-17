for file in *.patch ; do
	DATE_LINE=`grep 'Date:' $file | cut -f 2- -d :`
	echo "DateLine: ${DATE_LINE}"
	if [ -z "$DATE_LINE" ] ; then
		continue
	fi
	DATE=`date --date="$DATE_LINE" +%s`
	orig_file=`echo $file | cut -f 2- -d '_' `
	mv $file ${DATE}_${orig_file}
done
