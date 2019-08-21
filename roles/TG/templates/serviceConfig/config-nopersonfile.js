(function(global) {
  var config = {
    monitor: {
      dailyCountInterval: 5000,
    },
    cutboardFactor: {
      Pedestrian: 1,
      Vehicle: 1,
      Nonmotor: 1,
      Face: 1.2,
    },
    imgRetry: 2,
    org: {
      showSyncBtnToUsers: [],
    },
    searchEvent: {
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
    hideNavs: [
      '首页',
      '违法分析',
      '事件检索',
      '库碰撞',
      '轨迹分析',
      '统计分析',
      '陌生人',
      '日志管理',
      '运维管理',
      '全息档案',
    ],
    faceRepos: {
      Permanent: '0001',
    },
  };
  global.config = config;
})(window);
