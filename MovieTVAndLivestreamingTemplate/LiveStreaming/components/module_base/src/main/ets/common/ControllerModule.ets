export class ControllerModule {
  public static controllerMap: Map<string, TabsController> = new Map();

  public static set(controller: TabsController) {
    ControllerModule.controllerMap.set('TabsController', controller)
  }

  public static get(): TabsController | undefined {
    return ControllerModule.controllerMap.get('TabsController')
  }
}
