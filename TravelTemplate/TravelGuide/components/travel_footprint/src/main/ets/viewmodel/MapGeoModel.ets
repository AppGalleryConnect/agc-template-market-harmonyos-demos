export type GeoJSON = FeatureCollection

interface FeatureCollection {
  type: 'FeatureCollection';
  features: Feature[];
}

interface Feature {
  type: 'Feature';
  geometry: Geometry;
  properties: Properties;
  id?: string | number;
}

export type Geometry =  Polygon | MultiPolygon ;

interface Properties{
  adcode:number
  name:string
  center:[number, number]
}

export interface Polygon {
  type: 'Polygon';
  coordinates: Position[][];
}

export interface MultiPolygon {
  type: 'MultiPolygon';
  coordinates: Position[][][];
}

export type Position = [number, number] | [number, number, number]; // [经度, 纬度] 或 [经度, 纬度, 海拔]
