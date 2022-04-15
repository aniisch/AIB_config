#!/bin/bash
sudo useradd $1
mkdir sar && cd sar
wget https://fr.ids-imaging.com/files/downloads/ids-software-suite/software/linux-desktop/ids-software-suite-linux-4.94-64.tgz
tar xvfz ids-software-suite-linux-4.94-64.tgz 
sudo yes | ./ueye_4.94.0.1229_amd64.run 
sudo systemctl start ueyeusbdrc
sudo rm -r ids-software-suite-linux-4.94-64.tgz 
sudo snap install cmake --classic
sudo apt install -y build-essential git pkg-config libgtk-3-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
    libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
    gfortran openexr libatlas-base-dev python3-dev python3-numpy \
    libtbb2 libtbb-dev libdc1394-22-dev qt5-default libqt5websockets5-dev libopencv-dev libssl-dev uuid
mkdir sar/opencv_build && cd sar/opencv_build
git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git
cd sar/opencv_build/opencv
mkdir build && cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_C_EXAMPLES=ON \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_build/opencv_contrib/modules \
    -D BUILD_EXAMPLES=ON ..
make -j8
sudo make install
cd ../..
mkdir -p source/repos
cd source/repos
git clone https://anis.chaarana:ngxhaucfjxtjqlan7gqackt5ury42zmxborbx7y5djywf4euevxa@dev.azure.com/gdev-altametris/Vador/_git/Vador
cd Vador
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
make -j
sudo make install
sudo ldconfig
cd ../bin
#edit grabandserv.service for the right user SAR06
python3 ./ConfigUser.py $1
sudo cp grabandserv.service /etc/systemd/system/.
sudo mkdir -p /usr/share/alta/grabandserv/bin
#edit start.sh with the right uid  814950bd-85ba-41d9-b41f-ba5dbf2ee583
python3 ./ConfigGuid.py $2
sudo cp *.sh /usr/share/alta/grabandserv/bin/.
sudo mkdir -p /usr/share/alta/grabandserv/cfg
sudo cp ../cfg/*.ini /usr/share/alta/grabandserv/cfg/.
sudo chmod o+rx /usr/share/alta/grabandserv/bin/start.sh
sudo chmod o+rx /usr/share/alta/grabandserv/bin/stop.sh
sudo systemctl enable grabandserv
sudo systemctl set-default multi-user.target
