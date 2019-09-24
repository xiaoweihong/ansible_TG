(function(global) {
  var config = {
    featureCacheCapacity: 10,
    monitor: {
      dailyCountInterval: 5000,
    },
    cutboardFactor: {
      Pedestrian: 1,
      Vehicle: 1,
      Nonmotor: 1,
      Face: 1.5,
    },
    map: {
      animationDuration: 1000,
    },
    imgRetry: 2,
    export: {
      picProgressFactor: 0.9,
    },
    org: {
      showSyncBtnToUsers: [],
    },
    faceEventSearch: {
      defaultImagesConfidence: 0.8,
      modal: {
        searchCaptureFaces: {
          TimestampStartOffset: -86400000,
          TimestampEndOffset: 0,
          Confidence: 0.8,
          CountLimit: 5,
        },
        searchCivils: {
          Confidence: 0.8,
          CountLimit: 5,
        },
      },
      exportConfig: {
        Path: '/api/face/events',
        Type: 5,
        Fields: {
          EventImage: '抓拍人脸',
          MonitorRuleImage: '比对人脸',
          Confidence: '比对分值',
          Time: '报警时间',
          SensorName: '报警地点',
          RepoName: '所在库',
          Name: '姓名',
          IDNo: '身份证',
          Status: '审核状态',
          CheckPerson: '审核人',
        },
        InlineImage: true,
        RefreshInterval: 2000,
      },
    },
    capVehicleSearch: {
      exportConfig: {
        Path: '/api/vehicle/captures',
        Type: 2,
        Fields: {
          Time: '经过时间',
          SensorName: '设备名称',
          LicenseNumber: '车牌号码',
          Type: '车辆类型',
          BrandModel: '品牌型号',
          Color: '车辆颜色',
          LicenseType: '车牌类型',
          LicenseColor: '车牌颜色',
          Special: '特殊车辆',
          Symbol: '标识物',
          Direction: '目标方向',
          Speed: '目标速度',
          HasFace: '是否有人脸',
          OriginalImage: '高清图',
          FeatureImage: '特征图',
        },
        InlineImage: true,
        RefreshInterval: 2000,
      },
    },
    capPedestrianSearch: {
      exportConfig: {
        Path: '/api/pedestrian/captures',
        Type: 4,
        Fields: {
          Time: '经过时间',
          SensorName: '设备名称',
          HeadWear: '头部特征',
          Bag: '包',
          UpperColor: '上身颜色',
          UpperTexture: '上身纹理',
          LowerColor: '下身颜色',
          LowerType: '下身类别',
          AttachedItems: '附属物品',
          UpperType: '上衣款式',
          ShoesType: '鞋子款式',
          ShoesColor: '鞋子颜色',
          HairStyle: '发型',
          Age: '年龄',
          Gender: '性别',
          Direction: '目标方向',
          Speed: '目标速度',
          HasFace: '是否有人脸',
          OriginalImage: '高清图',
          FeatureImage: '特征图',
        },
        InlineImage: true,
        RefreshInterval: 2000,
      },
    },
    capNonmotorSearch: {
      exportConfig: {
        Path: '/api/nonmotor/captures',
        Type: 3,
        Fields: {
          Time: '经过时间',
          SensorName: '设备名称',
          Type: '车型',
          LicenseNumber: '车牌号牌',
          LicenseColor: '车牌颜色',
          Attitude: '车辆角度',
          Color: '车身颜色',
          UpperColor: '上衣颜色',
          UpperStyle: '上衣样式',
          HeadWear: '头部特征',
          AttachedItems: '附属物品',
          Gender: '性别',
          Direction: '目标方向',
          Speed: '目标速度',
          HasFace: '是否有人脸',
          OriginalImage: '高清图',
          FeatureImage: '特征图',
        },
        InlineImage: true,
        RefreshInterval: 2000,
      },
    },
    capFaceSearch: {
      exportConfig: {
        Path: '/api/face/captures',
        Type: 1,
        Fields: {
          Time: '经过时间',
          SensorName: '设备名称',
          Gender: '性别',
          Age: '年龄',
          Glass: '眼镜',
          Hat: '帽子',
          Helmet: '安全帽',
          Mask: '口罩',
          OriginalImage: '高清图',
          FeatureImage: '特征图',
        },
        InlineImage: true,
        RefreshInterval: 2000,
      },
    },
    player: {
      retry: 3,
      rtsp: {
        options: {
          type: 6,
          tcp: true,
          autoreconnect: true,
          hwdecoder: 0,
        },
      },
    },
    eventNotification: {
      loopAudio: true,
    },
    sensor: {
      refreshInterval: 2000,
      defaultPageParams: {
        Limit: 20,
        Offset: 0,
      },
      showSyncBtnToUsers: [],
    },
    task: {
      refreshInterval: 2000,
      defaultPageParams: {
        Limit: 10,
        Offset: 0,
      },
    },
    rule: {
      defaultPageParams: {
        Limit: 10,
      },
    },
    civilRepoSearch: {
      defaultPageParams: {
        Limit: 100,
        Offset: 0,
      },
    },
    repo: {
      refreshInterval: 2000,
    },
    civil: {
      maxImageCount: 15,
      batchAdd: {
        refreshInterval: 1000,
        maxSize: 536870912, // 500M
        maxSizeDisplayText: '500M',
        exts: ['zip', 'tar.gz', 'tar'],
      },
      batchDelete: {
        refreshInterval: 1000,
        exts: ['txt'],
      },
    },
    funcRole: {
      defaultRole: {
        Ts: 0,
        UserCount: 0,
        Id: '',
        Name: '',
        Comment: '',
        Content: '{"org": "r"}',
      },
    },
    user: {
      defaultUser: {
        UserId: '',
        ConfirmPwd: '',
        UserName: '',
        UserPassword: 'user@123',
        IsValid: true,
        RealName: '',
        Comment: '',
      },
    },
    eventWarningTimeout: 3000,
    videoUpload: {
      maxSize: 1073741824, // 1G
      exts: ['mp4', 'avi', 'mov', 'ts'],
      path: '/videos',
    },
    hideNavs: ['首页', '违法分析', '事件检索', '库碰撞', '轨迹分析', '统计分析', '陌生人', '日志管理', '运维管理'],
    faceRepos: {
      Permanent: '0001',
    },
    frequencyAnalysis: {
      maxSensorsLen: 500,
      differenceDay: 31,
      refreshInterval: 2000,
    },
  };
  global.config = config;
})(window);
