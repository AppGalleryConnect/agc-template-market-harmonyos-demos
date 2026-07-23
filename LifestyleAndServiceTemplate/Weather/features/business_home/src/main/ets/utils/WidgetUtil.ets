import { preferences } from '@kit.ArkData';
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { LocationInfo, Logger } from 'lib_foundation';
import { DailyWeather, HourlyWeather, RealTimeWeather, WeatherUtils } from 'module_weather_core';

const TAG = '[WidgetUtil]';

export class WidgetUtil {
  private static readonly _fileName: string = 'file_name';
  private static readonly _formIdKey: string = 'id_key';
  private static readonly _locationKey: string = 'location_key';
  private static readonly _formIdEventName: string = 'form_id_event_name';

  public static getFormIds(ctx: Context) {
    try {
      const store = WidgetUtil._getStore(ctx);
      return store.getSync(WidgetUtil._formIdKey, []) as string[];
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to get form ids. Code: ${err.code}, message: ${err.message}`);
      return [];
    }
  }

  public static async addFormId(formId: string, cxt: Context) {
    const list = WidgetUtil.getFormIds(cxt);
    if (!list.some(id => id === formId)) {
      list.push(formId);
      try {
        const store = WidgetUtil._getStore(cxt);
        store.putSync(WidgetUtil._formIdKey, list);
        await store.flush();
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(TAG, `Failed to add form id. Code: ${err.code}, message: ${err.message}`);
      }
    }
  }

  public static async delFormId(formId: string, cxt: Context) {
    const list = WidgetUtil.getFormIds(cxt);
    const index = list.findIndex(id => id === formId);
    if (index !== -1) {
      list.splice(index, 1);
      try {
        const store = WidgetUtil._getStore(cxt);
        store.putSync(WidgetUtil._formIdKey, list);
        await store.flush();
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(TAG, `Failed to delete form id. Code: ${err.code}, message: ${err.message}`);
      }
    }
  }

  // 发布公共事件跨进程传递卡片id
  public static publishFormId(formId: string, isDelete: boolean) {
    try {
      commonEventManager.publish(WidgetUtil._formIdEventName, { data: formId, parameters: { isDelete } },
        (err: BusinessError) => {
          if (err) {
            Logger.error(TAG, `Failed to publish common event. Code is ${err.code}, message is ${err.message}`);
          } else {
            Logger.info(TAG, 'Succeeded in publishing common event.');
          }
        });
    } catch (error) {
      Logger.error(TAG, 'Failed to commonEventManager.publish. Cause:' + JSON.stringify(error));
    }
  }

  // 订阅获取卡片id
  public static async subscribeFormId(ctx: Context) {
    let subscriber: commonEventManager.CommonEventSubscriber;
    let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: [WidgetUtil._formIdEventName],
      publisherPermission: '',
    };
    try {
      commonEventManager.createSubscriber(subscribeInfo, (err1, data1) => {
        if (err1) {
          Logger.error(TAG, `Failed to create subscriber. Code is ${err1.code}, message is ${err1.message}`);
          return;
        }
        subscriber = data1;
        // 订阅公共事件回调
        commonEventManager.subscribe(subscriber, (err2, data2) => {
          if (err2) {
            Logger.error(TAG, `Failed to subscribe common event. Code is ${err2.code}, message is ${err2.message}`);
            return;
          } else {
            if (data2.parameters?.isDelete) {
              WidgetUtil.delFormId(data2.data as string, ctx);
            } else {
              WidgetUtil.addFormId(data2.data as string, ctx);
            }
            Logger.info(TAG, 'Succeeded in creating subscriber1.');
          }
        });
      });
    } catch (error) {
      Logger.error(TAG, 'Failed to commonEventManager.createSubscriber. Cause:' + JSON.stringify(error));
    }
  }

  public static getLocation(ctx: Context) {
    try {
      const store = WidgetUtil._getStore(ctx);
      return store.getSync(WidgetUtil._locationKey, []) as LocationInfo;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to get location. Code: ${err.code}, message: ${err.message}`);
      return {} as LocationInfo;
    }
  }

  public static async setLocation(location: LocationInfo, ctx: Context) {
    const store = WidgetUtil._getStore(ctx);
    try {
      store.putSync(WidgetUtil._locationKey, location);
      store.flushSync();
    } catch (e) {
      Logger.info(TAG, JSON.stringify(e));
    }
  }

  /**
   * 更新服务卡片,获取最新数据
   * @param ctx 上下文
   * @param formId 指定卡片更新 或 全部更新
   */
  public static async updateWeatherInfo(ctx: Context, formId: string = '') {
    const location = WidgetUtil.getLocation(ctx);
    let realTimeWeather: RealTimeWeather | null = null;
    let hourlyWeather: HourlyWeather[] | null = null;
    let dailyWeather: DailyWeather[] | null = null;
    const promises = [
      WeatherUtils.getRealTimeWeathers([location.code]),
      WeatherUtils.getHourlyWeathers(location.code),
      WeatherUtils.getDailyWeathers(location.code),
    ];
    const results = await Promise.all(promises);
    results.forEach((item, index) => {
      if (index === 0) {
        realTimeWeather = (item as RealTimeWeather[])[0];
      } else if (index === 1) {
        hourlyWeather = item as HourlyWeather[];
      } else {
        dailyWeather = item as DailyWeather[];
      }
    });

    let formData: Record<string, LocationInfo | RealTimeWeather | HourlyWeather[] | DailyWeather[] |
    [ResourceColor, number][] | null> = {
      'location': location,
      'realTimeWeather': realTimeWeather,
      'hourlyWeather': hourlyWeather,
      'dailyWeather': dailyWeather,
      'colors': WidgetUtil._isDaytime() ? [['#2E6BE0', 0], ['#92C8FD', 1]] : [['#274668', 0], ['#527EAA', 1]],
    };
    if (formId) {
      try {
        formProvider.updateForm(formId, formBindingData.createFormBindingData(formData))
          .catch((error: BusinessError) => {
            Logger.error(TAG, 'Failed to formProvider.updateForm. Cause:' + JSON.stringify(error));
          });
      } catch (error) {
        Logger.error(TAG, 'Failed to formProvider.updateForm. Cause:' + JSON.stringify(error));
      }
    } else {
      WidgetUtil.getFormIds(ctx).forEach(id => {
        try {
          formProvider.updateForm(id, formBindingData.createFormBindingData(formData)).catch((error: BusinessError) => {
            Logger.error(TAG, 'Failed to formProvider.updateForm. Cause:' + JSON.stringify(error));
          });
        } catch (error) {
          Logger.error(TAG, 'Failed to formProvider.updateForm. Cause:' + JSON.stringify(error));
        }
      });
    }
  }

  private static _isDaytime(): boolean {
    const time = new Date();
    const hours = time.getHours();
    return hours >= 6 && hours < 18;
  }

  private static _getStore(ctx: Context) {
    try {
      return preferences.getPreferencesSync(ctx, { name: WidgetUtil._fileName });
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(TAG, `Failed to get preferences. Code: ${err.code}, message: ${err.message}`);
      throw new Error(`Failed to get preferences. Code: ${err.code}, message: ${err.message}`);
    }
  }
}