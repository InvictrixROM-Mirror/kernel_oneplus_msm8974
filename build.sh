#!/bin/bash

export kernel=Scorpion
export device=bacon
export deviceconfig=bacon_defconfig
export outdir=/home/kernel/Scorpion
export makeopts="-j$(nproc)"
export zImagePath="arch/arm/boot/zImage-dtb"
export KBUILD_BUILD_USER=USA-RedDragon
export KBUILD_BUILD_HOST=EdgeOfCreation
export CROSS_COMPILE="ccache ~/invictus/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/arm-linux-androideabi-"
export ARCH=arm
export shouldclean="0"
export istest="0"

export version=$(cat version)
export RDIR=$(pwd)

function build() {
    if [[ $shouldclean =~ "1" ]] ; then
        rm -rf build
    fi
    export deviceconfig="bacon_defconfig"
    export device="bacon"

    make -C ${RDIR} ${makeopts} ${deviceconfig}
    make -C ${RDIR} ${makeopts}
    make -C ${RDIR} ${makeopts} modules
    

    if [ -a ${zImagePath} ] ; then
        cp ${zImagePath} zip/zImage
	zip/dtbTool -o zip/dtb -s 2048 -p ./scripts/dtc/dtc ./arch/arm/boot/dts/
	mkdir -p zip/modules/
	find -name '*.ko' -exec cp -av {} zip/modules/ \;
        cd zip
        zip -q -r ${kernel}-${device}-${version}.zip anykernel.sh META-INF tools zImage dtb modules
    else
        echo -e "\n\e[31m***** Build Failed *****\e[0m\n"
    fi


    if ! [ -d ${outdir} ] ; then
        mkdir ${outdir}
    fi

    if [ -a ${kernel}-${device}-${version}.zip ] ; then
        mv -v ${kernel}-${device}-${version}.zip ${outdir}
    fi

    cd ${RDIR}

    rm -f zip/zImage
    rm -f zip/dtb
    rm -rf zip/modules
}

if [[ $1 =~ "clean" ]] ; then
    shouldclean="1"
fi

build
