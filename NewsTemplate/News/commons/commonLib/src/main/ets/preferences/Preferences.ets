import { preferences } from '@kit.ArkData';
import { CommonConstants } from '../constants/CommonContants';

let context = getContext(this);
let preference: preferences.Preferences;
let preferenceTemp: preferences.Preferences;

class NewsData{
  title:string=''
  content:string=''
  image?: Resource
  comment:string=''
  good:boolean=false
  collect:boolean=false
  share:number=0
}

/**
 * Preference model.
 *
 * @param fruitData Fruit data.
 */
export class PreferenceModel {
  private newsData: NewsData = new NewsData();

  /**
   * Read the specified Preferences persistence file and load the data into the Preferences instance.
   */
  async getPreferencesFromStorage() {
    try {
      preference = await preferences.getPreferences(context, CommonConstants.PREFERENCES_NAME);
    } catch (err) {
    }
  }

  /**
   * Deletes the specified Preferences persistence file from memory and removes the Preferences instance.
   */
  async deletePreferences() {
    try {
      await preferences.deletePreferences(context, CommonConstants.PREFERENCES_NAME);
    } catch(err) {
    };
    preference = preferenceTemp;
  }

  /**
   * Save the data to the Preferences.
   *
   * @param fruit Fruit data.
   */
  async putPreference(newsData: NewsData) {
    if (!preference) {
      await this.getPreferencesFromStorage();
    }
    // The fruit name and fruit quantity data entered by the user are saved to the cached Preference instance.
    try {
      await preference.put(CommonConstants.KEY_NAME, JSON.stringify(newsData));
    } catch (err) {
    }
    // Store the Preference instance in the preference persistence file
    await preference.flush();
  }

  /**
   * Get preference data.
   */
  async getPreference() {
    let newsData = '';
    if (!preference) {
      await this.getPreferencesFromStorage();
    }
    try {
      newsData = (await preference.get(CommonConstants.KEY_NAME, '')).toString();
    } catch (err) {
    }
    // If the data is empty, a message is displayed indicating that data needs to be written.
    if (newsData === '') {
      return null;
    }
    return JSON.parse(newsData);
  }

  /**
   * Process the data obtained from the database.
   */
  async getNewsData() {
    this.newsData = await this.getPreference();
    return this.newsData;
  }

  /**
   * Verifies that the data entered is not empty.
   *
   * @param fruit Fruit data.
   */
  checkNewsData(news: NewsData) {
    if (news.title === '' || news.content === '') {
      return true;
    }
    return false;
  }

  /**
   * write data.
   *
   * @param fruit  Fruit data.
   */
  writeData(news: NewsData) {
    // Check whether the data is null.
    let isDataNull = this.checkNewsData(news);
    if (isDataNull) {
      return;
    }
    // The data is inserted into the preferences database if it is not empty.
    this.putPreference(news);
  }
}

export default new PreferenceModel();