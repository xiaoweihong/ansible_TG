#!/bin/bash

WORK_DIR="/opt/bigtoe"
CONFIG_FILE=$WORK_DIR"/pkg/k8s-conf/deepengine/vse/config/template/init.val"

if [[ ! -f $CONFIG_FILE ]]; then
    PARAM_VERSION="WL"
else
    PARAM_VERSION="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="__APP_PARAM_VERSION__") print $2}')"
fi

if [[ "$PARAM_VERSION" == "" ]]; then
    PARAM_VERSION="WL"
fi

if [[ "$PARAM_VERSION" == "WL" ]]; then
    ENABLE_TRAJECT="true"
    WL_ENLARGE="true"
    PB_ALWAYS="true"
    PB_ENUM="false"
    VSE_FACE_MODEL_VERSION="1.8.1.0"
    FSE_FACE_MODEL_VERSION="cos-1.8.1.0"
fi

if [[ "$PARAM_VERSION" == "DV" ]]; then
    ENABLE_TRAJECT="false"
    WL_ENLARGE="false"
    PB_ALWAYS="false"
    PB_ENUM="true"
    VSE_FACE_MODEL_VERSION="1.8.1.0"
    FSE_FACE_MODEL_VERSION="cos-1.8.1.0"
fi

if [[ "$PARAM_VERSION" == "DC" ]]; then
    ENABLE_TRAJECT="false"
    WL_ENLARGE="false"
    PB_ALWAYS="true"
    PB_ENUM="true"
    VSE_FACE_MODEL_VERSION="2.7.3.0"
    FSE_FACE_MODEL_VERSION="cos-2.7.3.0"
fi

configVse () {
    sed -i -r "/\"EnableTraject\":/s#\"EnableTraject\":.*#\"EnableTraject\":$ENABLE_TRAJECT,#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/config/template/*.tpl
    sed -i -r "/\"WLEnlarge\":/s#\"WLEnlarge\":.*#\"WLEnlarge\":$WL_ENLARGE,#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/config/template/*.tpl
    sed -i -r "s#- \"-pb_always_print_primitive_fields=.*#- \"-pb_always_print_primitive_fields=$PB_ALWAYS\"#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/generate.php
    sed -i -r "s#- \"-pb_enum_as_number=.*#- \"-pb_enum_as_number=$PB_ENUM\"#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/generate.php
    sed -i -r "/MODEL_FACEFEATURE\#/s/MODEL_FACEFEATURE#.*/MODEL_FACEFEATURE\#$VSE_FACE_MODEL_VERSION/" $WORK_DIR/pkg/k8s-conf/deepengine/vse/config/template/public.val
}

configFse() {
    sed -i -r "/VERIFICATION\#/s/VERIFICATION#.*/VERIFICATION\#$FSE_FACE_MODEL_VERSION/" $WORK_DIR/pkg/k8s-conf/deepengine/fse/config/template/fse-node-config.val
}

main() {
    if [ ! -f $CONFIG_FILE ]; then
        echo "Config File $CONFIG_FILE Not Exists" 
        exit 1
    fi
    configVse
    configFse
}

main
