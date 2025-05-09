import { harTasks } from '@ohos/hvigor-ohos-plugin';
import path from 'path';
import * as fs from 'fs';
import { exec } from 'child_process';

interface OpenSourceInfo {
  name: string
  url: string
  tag: string
}

const THIRD_PARTY_PATH = 'commons/parse/src/main/cpp/third_party/';

export default {
  system: harTasks,
  plugins: [
    addOpenSource({
      "name": "pugixml",
      "url": "https://github.com/zeux/pugixml.git",
      "tag": "v1.14"
    })
  ]
}


function addOpenSource(info: OpenSourceInfo) {
  let projectRootPath = process.cwd();
  const thirdPartyPath = path.resolve(projectRootPath, THIRD_PARTY_PATH + info.name);

  console.info(thirdPartyPath);
  if (fs.existsSync(thirdPartyPath)) {
    return;
  }

  exec(`git clone -b ${info.tag} ${info.url} ${thirdPartyPath}`);
  console.info("success to add dependence");
}