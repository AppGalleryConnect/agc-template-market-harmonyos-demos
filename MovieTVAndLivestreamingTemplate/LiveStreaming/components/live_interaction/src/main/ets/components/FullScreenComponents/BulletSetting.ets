import { BulletSettingPanel } from '../../models/BulletSettingPanel'

@ComponentV2
export struct BulletSetting {

  @Param rowsNum: number = 2;
  @Param notOpacity: number = 80;
  @Param danMuSpeed: string = '适中';
  @Param danMuSize: string = '适中';
  @Event setRowsNum: Function = (set: number) => {};
  @Event setNotOpacity: Function = (set: number) => {};
  @Event setDanMuSpeed: Function = (set: string) => {};
  @Event setDanMuSize: Function = (set: string) => {};

  build() {
    BulletSettingPanel({
      rowsNum: this.rowsNum,
      notOpacity: this.notOpacity,
      danMuSpeed: this.danMuSpeed,
      danMuSize: this.danMuSize,
      autoSave: false,
      onRowsNumChange: (v) => { this.setRowsNum(v); },
      onNotOpacityChange: (v) => { this.setNotOpacity(v); },
      onDanMuSpeedChange: (v) => { this.setDanMuSpeed(v); },
      onDanMuSizeChange: (v) => { this.setDanMuSize(v); },
    })
  }
}