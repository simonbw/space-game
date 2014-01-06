package util;

import nape.geom.GeomPoly;
import nape.geom.Vec2;

/**
 * Used for fancy calculations on GeomPolys from nape.
 */
class Geom {
	
	/**
	 * Splits a geompoly from a point in a direction.
	 * @param	poly
	 * @param	cutPoint
	 * @param	cutDirection
	 */
	public static function crackPoly(poly:GeomPoly, cutStartPoint:Vec2, cutDirection:Vec2, timesToCrack:Int = 0):Array<GeomPoly> {
		var cutEndPoint = cutStartPoint.copy();
		cutDirection.normalise();
		cutStartPoint = cutStartPoint.sub(cutDirection);
		
		var n = 1000;
		while (poly.contains(cutStartPoint) && (n > 0)) {
			cutStartPoint.subeq(cutDirection);
			n--;
		}
		n = 100;
		while (!poly.contains(cutEndPoint) && (n > 0)) {
			cutEndPoint.addeq(cutDirection);
			n--;
		}
		n = 10000;
		do {
			cutEndPoint.addeq(cutDirection);
			n--;
		} while (poly.contains(cutEndPoint) && n > 0);
		if (poly.contains(cutStartPoint)) {
			Main.log("Cut start point in the polygon");
		}
		if (poly.contains(cutEndPoint)) {
			Main.log("Cut end point in the polygon");
		}

		var cutResults = poly.cut(cutStartPoint, cutEndPoint, true, true);
		if (cutResults.length != 2) {
			return [poly.copy()];
		}
		var polyA = cutResults.pop();
		var polyB = cutResults.pop();
		
		// I know this is is quadratic time and could be linear using a hashset,
		// but n is small and this is easy for now
		var commonPoints = new Array<Vec2>();	// points that are in both polygons
		for (a in polyA) {
			for (b in polyB) {
				if (Vec2.dsq(a, b) < 0.0001) {
					commonPoints.push(a.copy());
					break;
				}
			}
		}
		
		// Find one of the points for polygon A
		while (Vec2.dsq(polyA.current(), commonPoints[0]) > 0.0001) {
			polyA.skipForward(1);
		}
		// See if it is the first or second point
		polyA.skipBackwards(1);
		if (Vec2.dsq(polyA.current(), commonPoints[1]) > 0.0001) {
			polyA.skipForward(1);
		}
		// Find one of the points for polygon B
		while (Vec2.dsq(polyB.current(), commonPoints[0]) > 0.0001) {
			polyB.skipForward(1);
		}
		polyB.skipBackwards(1);
		// See if it is the first or second point
		if (Vec2.dsq(polyB.current(), commonPoints[1]) > 0.0001) {
			polyB.skipForward(1);
		}
		
		var variance = MyMath.min(polyA.area(), polyB.area()) / 200;
		var midpoint = Vec2.get(0.5 * commonPoints[0].x + 0.5 * commonPoints[1].x, 0.5 * commonPoints[0].y + 0.5 * commonPoints[1].y);
		var toAdd = midpoint.copy();
		do {
			toAdd.set(midpoint.add(Vec2.get(Random.normal(0, variance), Random.normal(0, variance), true)));
		} while (!poly.contains(toAdd));
		polyA.push(toAdd);
		polyB.push(toAdd);
		
		var results = new Array<GeomPoly>();
		if (timesToCrack > 0) {
			for (g in crackPoly(polyA, toAdd, Vec2.fromPolar(1, cutDirection.angle + Random.normal(Math.PI / 2, 0.4)))) {
				try { 
					for (g2 in g.simpleDecomposition()) {
						results.push(g2);
					}
				} catch (error:Dynamic) {
					
				}
			}
			for (g in crackPoly(polyB, toAdd, Vec2.fromPolar(1, cutDirection.angle + Random.normal(Math.PI / 2, 0.4)))) {
				for (g2 in g.simpleDecomposition()) {
					results.push(g2);
				}
			}
		} else {
			results.push(polyA);
			results.push(polyB);
		}
		
		cutStartPoint.dispose();
		cutEndPoint.dispose();
		midpoint.dispose();
		toAdd.dispose();
		
		return results;
	}
	
}