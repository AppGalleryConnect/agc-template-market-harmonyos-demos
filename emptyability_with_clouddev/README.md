# clouddev
[![license](https://img.shields.io/badge/license-Apache--2.0-green)](./LICENCE)

This repo contains the source code for agc-HarmonyOS-demos, which are developed by the AppGallery Connect team.

These demos enable access to using specific API6. For more information
about demos, and how to use them, see
[Official Documentations](https://developer.huawei.com/consumer/en/doc/development/AppGallery-connect-Guides/agc-get-started-harmonyos-0000001184684961).


## Introduction
    1. Use Deveco Studio create Empty Ability With Clouddev project.
![image](https://user-images.githubusercontent.com/1013629/223935818-3bdf5f0f-5ed0-4ad3-b5bb-e1d803c3a535.png)

    2. Deploy function "idgenerator".
![image](https://user-images.githubusercontent.com/1013629/223936105-3178fdb8-bdb0-4294-abcd-4bb7df0f20c8.png)

    3. Download this project code.
![image](https://user-images.githubusercontent.com/1013629/223936258-4f994f58-040d-433a-9fea-6cfaa709b4ff.png)


    4. Use Deveco Studio open this project "emptyability_with_clouddev"
    
    5. Refactor package name "com.huawei.clouddev"
![image](https://user-images.githubusercontent.com/1013629/223936948-55bf5de9-48fb-4c09-86c4-938748a33f14.png)
![image](https://user-images.githubusercontent.com/1013629/223937208-6cdecefd-6bac-4326-adca-ab8c85adcaf3.png)

    6. Login AppGallery Connect and download agconnect-services.json, then put it into entry/src/main/resource/rawfile directory.
![image](https://user-images.githubusercontent.com/1013629/223942100-384cff3e-664f-4477-ab09-af523516be97.png)
  
    7. In Deveco Studio click File->Project Structure -> Projects -> Signing Configs and select "Automatically generate signature".
![image](https://user-images.githubusercontent.com/1013629/223938411-1944537f-5451-4b35-8966-fccdccbeb5c4.png)

    8. Connect to your phone and run.
	
## Precautions
The agc-HarmonyOS-demos project contains few independent projects. After downloading the code, you can load different nested projects to the IDE as required. And you can run each project independently.

## Question or issues
If you have questions about how to use AppGallery Connect Demos, try the following options:
* [Stack Overflow](https://stackoverflow.com/questions/tagged/appgallery) is the best place for any programming questions. Be sure to tag your question with appgallery or appgallery connect.
* [Huawei Developer Forum](https://forums.developer.huawei.com/forumPortal/en/home?fid=0101188387844930001) AppGallery Module is great for general questions, or seeking recommendations and opinions.
* [Submit ticket online](https://developer.huawei.com/consumer/en/support/feedback/#/) If you encounter a serious or urgent problem, submit a trouble ticket online to contact Huawei technical support.

If you run into a bug in our samples, please submit an [issue](https://github.com/AppGalleryConnect/agc-android-demos/issues) to the Repository. Even better you can submit a [Pull Request](https://github.com/AppGalleryConnect/agc-android-demos/pulls) with a fix.
