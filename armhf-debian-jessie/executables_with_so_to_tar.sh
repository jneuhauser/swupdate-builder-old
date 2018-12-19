#!/bin/bash

function print_usage()
{
	echo ${0}:
	echo
	echo "      first param  : destination path"
	echo "      next params  : installed executables/commands name without path"
	echo "                     eg.: mount cat ..."
	echo
	exit 1
}

DST=${1}
[ -d "${DST}" ] || print_usage

# strip of first param
ELFS=$(echo ${@} | cut -d' ' -f2-)
[ "${ELFS}" = "" ] && print_usage
for test in ${ELFS}
do
	command -v ${test} >/dev/null 2>&1 || { echo >&2 "${test} not found.  Aborting."; exit 1; }
done

command -v lddtree >/dev/null 2>&1 || { echo >&2 "lddtree (package: pax-utils) required.  Aborting."; exit 1; }

# param 1: type (executable,other)
# param 2: file path
# param 3: rootfs path (root path + file path = full path)
function copy_file()
{
	file=${1}
	dst=${2}

	# ensure destination path exist
	mkdir -p ${dst}

	# check if readable
	if [ -r ${file} ]
	then
		# check for symlink
		if [ -L ${file} ]
		then
			link_target=$(readlink -f ${file})

			# check if destination already exist
			if [ ! -e "${dst}/${link_target}" ]
			then
				# ensure target destination path exist
				mkdir -p "${dst}/${link_target%/*}"

				# copy link target
				cp "${link_target}" "${dst}/${link_target}"
			fi

			# check if destination already exist
			if [ ! -e "${dst}/${file}" ]
			then
				# ensure target destination path exist
                        	mkdir -p "${dst}/${file%/*}"

				# create relative symlink
				ln -rs "${dst}/${link_target}" "${dst}/${file}"
			fi
		else
			# check if destination already exist
			if [ ! -e "${dst}/${file}" ]
                        then
				# ensure target destination path exist
                        	mkdir -p "${dst}/${file%/*}"

                        	# copy file
                        	cp "${file}" "${dst}/${file}"
			fi
		fi
	else
		echo "error: copy_file: ${file} not readable"
		exit 1
	fi

	return 0
}

# create temp folder
DST_TMP=${DST}/tmp
[ -e ${DST_TMP} ] && { echo >&2 "Temp folder ${DST_TMP} exist. please remove or backup. Aborting."; exit 1; }
mkdir -p ${DST_TMP}

# iterate over all
for EXE in ${ELFS}
do
	# grep and copy all needed files for executable
	for exe in $(lddtree -l $(which ${EXE}) 2>/dev/null)
	do
		copy_file ${exe} ${DST_TMP}
	done
done

# preserver work dir and move to tmp dir
WORKDIR=$(pwd)
cd ${DST_TMP}

# print info
echo
ls -lAhR
echo
echo "#######################################################"
echo
echo "   Complete size: $(du -sh) ${ELFS} + shared objects"

# create tar archiv 
TAR_NAME="$(echo ${ELFS// /_})-$(uname -m).tar.gz"
tar -czf "../${TAR_NAME}" ./*

# print archiv size info
echo
echo "   Archiv size: $(du -sh ../${TAR_NAME})"
echo

# restore work dir
cd ${WORKDIR}

# clean up
rm -rf ${DST_TMP}

exit 0

