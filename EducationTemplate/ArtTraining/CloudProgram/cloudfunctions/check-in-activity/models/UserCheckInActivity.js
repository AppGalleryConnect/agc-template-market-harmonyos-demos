/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2020-2020. All rights reserved.
 * Generated by the CloudDB ObjectType compiler. DO NOT EDIT!
 */

class UserCheckInActivity {
  getFieldTypeMap() {
    let fieldTypeMap = new Map();
    fieldTypeMap.set('id', 'String');
    fieldTypeMap.set('activityId', 'Integer');
    fieldTypeMap.set('userId', 'String');
    fieldTypeMap.set('name', 'String');
    fieldTypeMap.set('summary', 'String');
    fieldTypeMap.set('detail', 'Text');
    fieldTypeMap.set('mainDiagram', 'String');
    fieldTypeMap.set('price', 'Float');
    fieldTypeMap.set('requirement', 'Text');
    fieldTypeMap.set('status', 'Integer');
    fieldTypeMap.set('orderTime', 'String');
    fieldTypeMap.set('taskDirectory', 'Text');
    fieldTypeMap.set('participationCount', 'Integer');
    fieldTypeMap.set('historyCount', 'Integer');
    return fieldTypeMap;
  }

  getClassName() {
    return 'UserCheckInActivity';
  }

  getPrimaryKeyList() {
    let primaryKeyList = [];
    primaryKeyList.push('id');
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

  setId(id) {
    this.id = id;
  }

  getId() {
    return this.id;
  }

  setActivityId(activityId) {
    this.activityId = activityId;
  }

  getActivityId() {
    return this.activityId;
  }

  setUserId(userId) {
    this.userId = userId;
  }

  getUserId() {
    return this.userId;
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

  setStatus(status) {
    this.status = status;
  }

  getStatus() {
    return this.status;
  }

  setOrderTime(orderTime) {
    this.orderTime = orderTime;
  }

  getOrderTime() {
    return this.orderTime;
  }

  setTaskDirectory(taskDirectory) {
    this.taskDirectory = taskDirectory;
  }

  getTaskDirectory() {
    return this.taskDirectory;
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
}

module.exports = { UserCheckInActivity };
