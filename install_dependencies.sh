#!/bin/bash
set -e
set -x

start_dir=$(pwd)

BOWTIE2_VERSION=2.3.1
PRIMER3_VERSION=2.3.7

BOWTIE2_DOWNLOAD_URL="http://downloads.sourceforge.net/project/bowtie-bio/bowtie2/${BOWTIE2_VERSION}/bowtie2-${BOWTIE2_VERSION}-legacy-linux-x86_64.zip"
PRIMER3_DOWNLOAD_URL="http://downloads.sourceforge.net/project/primer3/primer3/${PRIMER3_VERSION}/primer3-${PRIMER3_VERSION}.tar.gz"

# Make an install location
if [ ! -d 'build' ]; then
  mkdir build
fi
cd build
build_dir=$(pwd)

# DOWNLOAD ALL THE THINGS
download () {
  url=$1
  download_location=$2

  if [ -e $download_location ]; then
    echo "Skipping download of $url, $download_location already exists"
  else
    echo "Downloading $url to $download_location"
    wget $url -O $download_location
  fi
}

# --------------- primer3 ------------------
cd $build_dir
download $PRIMER3_DOWNLOAD_URL "primer3-${PRIMER3_VERSION}.tar.gz"
primer3_dir="$build_dir/primer3-${PRIMER3_VERSION}"
tar -zxf primer3-${PRIMER3_VERSION}.tar.gz
cd $primer3_dir"/src"
make all
# --------------- bowtie2 ------------------
cd $build_dir
download $BOWTIE2_DOWNLOAD_URL "bowtie2-${BOWTIE2_VERSION}-legacy.zip"
bowtie2_dir="$build_dir/bowtie2-${BOWTIE2_VERSION}-legacy"
unzip -n bowtie2-${BOWTIE2_VERSION}-legacy.zip

cd $start_dir

update_path () {
  new_dir=$1
  if [[ ! "$PATH" =~ (^|:)"${new_dir}"(:|$) ]]; then
    export PATH=${new_dir}:${PATH}
  fi
}

pip3 install pysam

update_path "${bowtie2_dir}"
update_path "${primer3_dir}"
update_path "${primer3_dir}/src"

echo "Add the following line to your ~/.bashrc profile"
echo "export PATH=${bowtie2_dir}:${primer3_dir}:${primer3_dir}/src:${PATH}"
