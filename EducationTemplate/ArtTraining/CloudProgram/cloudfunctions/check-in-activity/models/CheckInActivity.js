/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2020-2020. All rights reserved.
 * Generated by the CloudDB ObjectType compiler. DO NOT EDIT!
 */

class CheckInActivity {
  getFieldTypeMap() {
    let fieldTypeMap = new Map();
    fieldTypeMap.set('activityId', 'Integer');
    fieldTypeMap.set('name', 'String');
    fieldTypeMap.set('summary', 'String');
    fieldTypeMap.set('detail', 'Text');
    fieldTypeMap.set('mainDiagram', 'String');
    fieldTypeMap.set('price', 'Float');
    fieldTypeMap.set('requirement', 'Text');
    fieldTypeMap.set('participationCount', 'Integer');
    fieldTypeMap.set('historyCount', 'Integer');
    fieldTypeMap.set('taskDirectory', 'Text');
    return fieldTypeMap;
  }

  getClassName() {
    return 'CheckInActivity';
  }

  getPrimaryKeyList() {
    let primaryKeyList = [];
    primaryKeyList.push('activityId');
    return primaryKeyList;
  }

  getIndexList() {
    let indexList = [];
    return indexList;
  }

  getEncryptedFieldList() {
    let encryptedFieldList = [];
    return encryptedFieldList;
  }

  setActivityId(activityId) {
    this.activityId = activityId;
  }

  getActivityId() {
    return this.activityId;
  }

  setName(name) {
    this.name = name;
  }

  getName() {
    return this.name;
  }

  setSummary(summary) {
    this.summary = summary;
  }

  getSummary() {
    return this.summary;
  }

  setDetail(detail) {
    this.detail = detail;
  }

  getDetail() {
    return this.detail;
  }

  setMainDiagram(mainDiagram) {
    this.mainDiagram = mainDiagram;
  }

  getMainDiagram() {
    return this.mainDiagram;
  }

  setPrice(price) {
    this.price = price;
  }

  getPrice() {
    return this.price;
  }

  setRequirement(requirement) {
    this.requirement = requirement;
  }

  getRequirement() {
    return this.requirement;
  }

  setParticipationCount(participationCount) {
    this.participationCount = participationCount;
  }

  getParticipationCount() {
    return this.participationCount;
  }

  setHistoryCount(historyCount) {
    this.historyCount = historyCount;
  }

  getHistoryCount() {
    return this.historyCount;
  }

  setTaskDirectory(taskDirectory) {
    this.taskDirectory = taskDirectory;
  }

  getTaskDirectory() {
    return this.taskDirectory;
  }
}

module.exports = { CheckInActivity };
