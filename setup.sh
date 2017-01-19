#!/usr/bin/env sh

function sedi {
    if [ $IS_MAC_OSX == 1 ]
    then
        sed -i ".original" $1 $2
    else
        sed -i.original $1 $2
    fi;
}

if [ "$(uname)" != "Darwin" ]; then
    IS_MAC_OSX=0
    echo "Detected a non MAX OS X platform"
else
    IS_MAC_OSX=1
    echo "Detect Mac OS X platform"
fi

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ -z "${SCRIPT_DIR}" ]; then
	echo "Error! Script directory is empty. This should not be possible."
	exit 1;
fi

VENDOR_NAME=$1
MODULE_NAME=$2
COMPOSER_NAME=$3

if [ -z "${VENDOR_NAME}" ]; then
	echo "Please enter a vendor name."
	exit 1;
fi

if [ -z "${MODULE_NAME}" ]; then
        echo "Please enter a module name."
	exit 1
fi

if [ -z "${COMPOSER_NAME}" ]; then
        echo "Please enter a composer package name."
        exit 1
fi

echo "Vendor name: ${VENDOR_NAME}"
echo "Module name: ${MODULE_NAME}"
echo "Composer package name: ${COMPOSER_NAME}"

VENDOR_NAME_LOWER=$(echo ${VENDOR_NAME} | tr '[:upper:]' '[:lower:]')
MODULE_NAME_LOWER=$(echo ${MODULE_NAME} | tr '[:upper:]' '[:lower:]')

for i in $(find ${SCRIPT_DIR} -name "Vendor")
do
	dir=$(dirname "$i")
	echo "$i -> $dir/${VENDOR_NAME}"
	mv $i "$dir/${VENDOR_NAME}"
done

for i in $(find ${SCRIPT_DIR} -name "Module")
do
    dir=$(dirname "$i")
    echo "$i -> $dir/${MODULE_NAME}"
	mv $i "$dir/${MODULE_NAME}"
done

for i in $(find ${SCRIPT_DIR} -name "Vendor_Module.xml")
do
    dir=$(dirname "$i")
    echo "$i -> $dir/${VENDOR_NAME}_${MODULE_NAME}.xml"
	mv $i "$dir/${VENDOR_NAME}_${MODULE_NAME}.xml"
done

for i in $(find ${SCRIPT_DIR} -name "vendor_module_setup")
do
    dir=$(dirname "$i")
    echo "$i -> $dir/${VENDOR_NAME_LOWER}_${MODULE_NAME_LOWER}_setup"
	mv $i "$dir/${VENDOR_NAME_LOWER}_${MODULE_NAME_LOWER}_setup"
done

for i in $(find ${SCRIPT_DIR} -name "*.php")
do
	echo "Replacing 'Vendor_Module' with '${VENDOR_NAME}_${MODULE_NAME}' in $i..."
	sedi "s/Vendor_Module/${VENDOR_NAME}_${MODULE_NAME}/g" $i
done

for i in $(find ${SCRIPT_DIR} -name "*.xml")
do
    echo "Replacing 'Vendor_Module' with '${VENDOR_NAME}_${MODULE_NAME}' in $i..."
    sedi "s/Vendor_Module/${VENDOR_NAME}_${MODULE_NAME}/g" $i
done

for i in $(find ${SCRIPT_DIR} -name "*.xml")
do
    echo "Replacing 'vendor_module' with '${VENDOR_NAME_LOWER}_${MODULE_NAME_LOWER}' in $i..."
    sedi "s/vendor_module/${VENDOR_NAME_LOWER}_${MODULE_NAME_LOWER}/g" $i
done

file="${SCRIPT_DIR}/modman"
echo "Replacing 'Vendor_Module' with '${VENDOR_NAME}_${MODULE_NAME}' in $file..."
sedi "s/Vendor_Module/${VENDOR_NAME}_${MODULE_NAME}/g" $file
echo "Replacing 'Vendor/Module' with '${VENDOR_NAME}/${MODULE_NAME}' in $file..."
sedi "s|Vendor/Module|${VENDOR_NAME}/${MODULE_NAME}|g" $file

file="${SCRIPT_DIR}/composer.json"
echo "Replacing 'module/vendor' with '${COMPOSER_NAME}' in $file..."
sedi "s|vendor/module|${COMPOSER_NAME}|g" $file

for i in $(find ${SCRIPT_DIR} -name "*.original")
do
    echo "Removing $i..."
    rm $i
done

echo "Removing .git files"
rm -rf "${SCRIPT_DIR}/.git/"

echo "Removing myself (${BASH_SOURCE[0]})! :("
rm -f "${BASH_SOURCE[0]}"
