sudo rm -rf  *gdal* 
sudo  rm -rf *proj* 
sudo  rm -rf *geos*
export BUILD_DIR=`pwd`
export BUILD_NAME="ccc"
GDAL_FILENAME=`w3m -dump http://download.osgeo.org/gdal/ | grep -o  gdal-[0-9.]*tar\\.gz | sort -rV | head -1`
GEOS_FILENAME=`w3m -dump http://download.osgeo.org/geos/ | grep -o  geos-[0-9.]*tar\\.bz2 | sort -rV | head -1`
PROJ_FILENAME=`w3m -dump http://download.osgeo.org/proj/ | grep -o  proj-[0-9b.]*tar\\.gz | sort -rV | head -1`
RGEOS_FILENAME=`w3m -dump http://cran.r-project.org/src/contrib/ | grep -o  rgeos_[0-9.//-]*tar\\.gz | sort -rV | head -1`
RGDAL_FILENAME=`w3m -dump http://cran.r-project.org/src/contrib/ | grep -o  rgdal_[0-9.//-]*tar\\.gz | sort -rV | head -1`
PROJ_DATUMGRID=`w3m -dump http://download.osgeo.org/proj/  | grep -o  proj-datumgrid[0-9.//-]*tar\\.gz | sort -rV | head -1`

export GDAL_FILENAME  GEOS_FILENAME  PROJ_FILENAME  RGEOS_FILENAME   RGDAL_FILENAME  PROJ_DATUMGRID
wget http://cran.r-project.org/src/contrib/$RGEOS_FILENAME
wget http://download.osgeo.org/geos/$GEOS_FILENAME
wget http://cran.r-project.org/src/contrib/$RGDAL_FILENAME
wget http://download.osgeo.org/gdal/$GDAL_FILENAME
wget http://download.osgeo.org/proj/$PROJ_FILENAME
wget http://download.osgeo.org/proj/$PROJ_DATUMGRID

tar xzvf $GDAL_FILENAME 
tar xzvf $RGDAL_FILENAME 
tar xzvf $RGEOS_FILENAME 
tar xvf  $GEOS_FILENAME
tar xzvf $PROJ_FILENAME




cd proj-*
export PROJ_DIR=`pwd`
cd nad
tar xvzf ../../$PROJ_DATUMGRID
cd ..
mkdir $BUILD_NAME
./configure  --without-jni --prefix=$PWD/$BUILD_NAME
make clean
make -j2
make install
cd ..
cd geos-*
export GEOS_DIR=`pwd`
mkdir $BUILD_NAME
./configure --prefix=$PWD/$BUILD_NAME
make clean
make -j2
make install
cd ..

cd gdal-*
mkdir $BUILD_NAME
export GDAL_DIR=`pwd`
./configure --prefix=$PWD/$BUILD_NAME --with-geos=$GEOS_DIR/$BUILD_NAME/bin/geos-config --with-static-proj4=$PROJ_DIR/$BUILD_NAME/ 

make clean
make -j2
make install
cd ..
export LD_LIBRARY_PATH=$GEOS_DIR/$BUILD_NAME/lib:$PROJ_DIR/$BUILD_NAME/lib:$GDAL_DIR/$BUILD_NAME/lib:$LD_LIBRARY_PATH

sudo R CMD REMOVE  rgdal
sudo R CMD REMOVE  rgeos

R CMD INSTALL $RGEOS_FILENAME  --byte-compile  --configure-args='--with-geos-config=$GEOS_DIR/$BUILD_NAME/bin/geos-config   --host=amd64-linux '
R CMD INSTALL  $RGDAL_FILENAME --byte-compile --configure-args='--with-gdal-config=$GDAL_DIR/$BUILD_NAME/bin/gdal-config --with-proj-include=$PROJ_DIR/$BUILD_NAME/include --with-proj-lib=$PROJ_DIR/$BUILD_NAME/lib  --host=amd64-linux'
