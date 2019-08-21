#!/bin/bash

WORK_DIR="/opt/bigtoe"
CONFIG_FILE="/etc/bigtoe/flags/app_config"

if [[ ! -f $CONFIG_FILE ]]; then
    PARAM_VERSION="WL"
else
    PARAM_VERSION="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="param_version") print $2}')"
fi

if [[ "$PARAM_VERSION" == "" ]]; then
    PARAM_VERSION="WL"
fi

if [[ "$PARAM_VERSION" == "WL" ]]; then
    ENABLE_TRAJECT="true"
    WL_ENLARGE="true"
    PB_ALWAYS="true"
    PB_ENUM="false"
fi

if [[ "$PARAM_VERSION" == "DV" ]]; then
    ENABLE_TRAJECT="false"
    WL_ENLARGE="false"
    PB_ALWAYS="false"
    PB_ENUM="true"
fi

configVse () {
    KAFKA_ADDR="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="kafka_addr") print $2}')"
    KAFKA_VIDEO_TOPIC="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="kafka_video_topic") print $2}')"
    KAFKA_IMAGE_TOPIC="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="kafka_image_topic") print $2}')"
    IMAGE_STORAGE="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="image_storage") print $2}')"
    LOCAL_LICENSE="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="local_license") print $2}')"

    sed -i -r "/\"Kafka\":/s#\"Kafka\":.*#\"Kafka\": { \"Enable\": true, \"Addr\": \"$KAFKA_ADDR\", \"Topic\": \"$KAFKA_VIDEO_TOPIC\", \"EnableTraject\": $ENABLE_TRAJECT, \"AllObjsSendMode\": false, \"Version\": \"1.0\" },#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap-keyframe*
    sed -i -r "/\"Kafka\":/s#\"Kafka\":.*#\"Kafka\": { \"Enable\": true, \"Addr\": \"$KAFKA_ADDR\", \"Topic\": \"$KAFKA_VIDEO_TOPIC\", \"EnableTraject\": $ENABLE_TRAJECT, \"AllObjsSendMode\": false, \"Version\": \"1.0\" },#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap-video*
    sed -i -r "/\"Arcee\":/s#\"Arcee\":.*#\"Arcee\": { \"Enable\": true, \"Addr\": \"$IMAGE_STORAGE\", \"WLEnlarge\": $WL_ENLARGE, \"FullImage\": true, \"CutboardImage\": true },#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap-keyframe*
    sed -i -r "/\"Arcee\":/s#\"Arcee\":.*#\"Arcee\": { \"Enable\": true, \"Addr\": \"$IMAGE_STORAGE\", \"WLEnlarge\": $WL_ENLARGE, \"FullImage\": true, \"CutboardImage\": true },#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap-video*
    sed -i -r "/\"Kafka\":/s#\"Kafka\":.*#\"Kafka\": { \"Enable\": true, \"Addr\": \"$KAFKA_ADDR\", \"Topic\": \"$KAFKA_IMAGE_TOPIC\", \"EnableTraject\": $ENABLE_TRAJECT, \"AllObjsSendMode\": true, \"Version\": \"1.0\" },#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap-image*
    sed -i -r "/\"Arcee\":/s#\"Arcee\":.*#\"Arcee\": { \"Enable\": false, \"Addr\": \"$IMAGE_STORAGE\", \"WLEnlarge\": $WL_ENLARGE, \"FullImage\": true, \"CutboardImage\": true },#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap-image*

    sed -i -r "/\"LocalProvince\":/s#\"LocalProvince\":.*#\"LocalProvince\": \"$LOCAL_LICENSE\"#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap*
    sed -r -i "s#- \"-pb_always_print_primitive_fields=.*#- \"-pb_always_print_primitive_fields=$PB_ALWAYS\"#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/generate.php
    sed -r -i "s#- \"-pb_enum_as_number=.*#- \"-pb_enum_as_number=$PB_ENUM\"#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/generate.php

    VSE_BeltPhone="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="VSE_BeltPhone") print $2}')"
    VSE_DangerCar="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="VSE_DangerCar") print $2}')"
    VSE_ZhatuChe="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="VSE_ZhatuChe") print $2}')"
    VSE_YellowMark="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="VSE_YellowMark") print $2}')"
    VSE_FaceCover="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="VSE_FaceCover") print $2}')"
    VSE_PlateCover="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="VSE_PlateCover") print $2}')"
    VSE_TempPlate="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="VSE_TempPlate") print $2}')"
    VSE_Antenna="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="VSE_Antenna") print $2}')"
    VSE_CarDamage="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="VSE_CarDamage") print $2}')"
    VSE_RedRope="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="VSE_RedRope") print $2}')"
    VSE_SecondClassify="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="VSE_SecondClassify") print $2}')"
    VSE_SkinColor="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="VSE_SkinColor") print $2}')"
    Image_BeltPhone="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="Image_BeltPhone") print $2}')"
    Image_DangerCar="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="Image_DangerCar") print $2}')"
    Image_ZhatuChe="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="Image_ZhatuChe") print $2}')"
    Image_YellowMark="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="Image_YellowMark") print $2}')"
    Image_FaceCover="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="Image_FaceCover") print $2}')"
    Image_PlateCover="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="Image_PlateCover") print $2}')"
    Image_TempPlate="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="Image_TempPlate") print $2}')"
    Image_Antenna="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="Image_Antenna") print $2}')"
    Image_CarDamage="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="Image_CarDamage") print $2}')"
    Image_RedRope="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="Image_RedRope") print $2}')"
    Image_SecondClassify="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="Image_SecondClassify") print $2}')"
    Image_SkinColor="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="Image_SkinColor") print $2}')"

    sed -i -r "/\"VSE\":/s#\"VSE\":.*#\"VSE\": { \"YellowMark\": $VSE_YellowMark, \"ZhatuChe\": $VSE_ZhatuChe, \"DangerCar\": $VSE_DangerCar, \"RedRope\": $VSE_RedRope, \"TempPlate\": $VSE_TempPlate, \"FaceCover\": $VSE_FaceCover, \"BeltPhone\": $VSE_BeltPhone, \"Antenna\": $VSE_Antenna, \"SkinColor\": $VSE_SkinColor, \"PlateCover\": $VSE_PlateCover, \"CarDamage\": $VSE_CarDamage, \"SecondClassify\": $VSE_SecondClassify },#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap*
    sed -i -r "/\"Image\":/s#\"Image\":.*#\"Image\": { \"YellowMark\": $Image_YellowMark, \"ZhatuChe\": $Image_ZhatuChe, \"DangerCar\": $Image_DangerCar, \"RedRope\": $Image_RedRope, \"TempPlate\": $Image_TempPlate, \"FaceCover\": $Image_FaceCover, \"BeltPhone\": $Image_BeltPhone, \"Antenna\": $Image_Antenna, \"SkinColor\": $Image_SkinColor, \"PlateCover\": $Image_PlateCover, \"CarDamage\": $Image_CarDamage, \"SecondClassify\": $Image_SecondClassify },#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap*

    CarBackFeature="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="CarBackFeature") print $2}')"
    CarFrontFeature="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="CarFrontFeature") print $2}')"
    NonvFeature="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="NonvFeature") print $2}')"
    PersonFeature="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="PersonFeature") print $2}')"
    FaceFeature="$(cat $CONFIG_FILE | awk -F '#' '{if($1=="FaceFeature") print $2}')"

    sed -i -r  "/\"CarBackFeature\":/s#\"CarBackFeature\":.*#\"CarBackFeature\": \"$CarBackFeature\",#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap*
    sed -i -r  "/\"CarFrontFeature\":/s#\"CarFrontFeature\":.*#\"CarFrontFeature\": \"$CarFrontFeature\",#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap*
    sed -i -r  "/\"NonvFeature\":/s#\"NonvFeature\":.*#\"NonvFeature\": \"$NonvFeature\",#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap*
    sed -i -r  "/\"PersonFeature\":/s#\"PersonFeature\":.*#\"PersonFeature\": \"$PersonFeature\",#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap*
    sed -i -r  "/\"FaceFeature\":/s#\"FaceFeature\":.*#\"FaceFeature\": \"$FaceFeature\"#" $WORK_DIR/pkg/k8s-conf/deepengine/vse/vse-configmap*

}

main() {
    if [ ! -f $CONFIG_FILE ]; then
        echo "Config File $CONFIG_FILE Not Exists" 
        exit 1
    fi
    configVse
}

main
