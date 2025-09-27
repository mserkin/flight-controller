//import * as THREE from "three.moin.js";
//import { SVGLoader } from 'three/examples/jsm/loaders/SVGLoader.js';
//const loader = new SVGLoader();

var canvasWidth = window.innerWidth;
var canvasHeight = window.innerHeight;

const xAxis = new THREE.Vector3(1, 0, 0);
const yAxis = new THREE.Vector3(0, 1, 0);
const zAxis = new THREE.Vector3(0, 0, 1);

function toRad(angle) {
	return THREE.MathUtils.degToRad(angle);
}

THREE.Quaternion.prototype.setFromBasis = function(e1, e2, e3) {
    const   m11 = e1.x, m12 = e1.y, m13 = e1.z,
            m21 = e2.x, m22 = e2.y, m23 = e2.z,
            m31 = e3.x, m32 = e3.y, m33 = e3.z,
            trace = m11 + m22 + m33;
    if (trace > 0) {
        const s = 0.5 / Math.sqrt(trace + 1.0);
        this._w = 0.25 / s;
        this._x = -(m32 - m23) * s;
        this._y = -(m13 - m31) * s;
        this._z = -(m21 - m12) * s;
    } else if (m11 > m22 && m11 > m33) {
        const s = 2.0 * Math.sqrt(1.0 + m11 - m22 - m33);
        this._w = (m32 - m23) / s;
        this._x = -0.25 * s;
        this._y = -(m12 + m21) / s;
        this._z = -(m13 + m31) / s;
    } else if (m22 > m33) {
        const s = 2.0 * Math.sqrt(1.0 + m22 - m11 - m33);
        this._w = (m13 - m31) / s;
        this._x = -(m12 + m21) / s;
        this._y = -0.25 * s;
        this._z = -(m23 + m32) / s;
    } else {
        const s = 2.0 * Math.sqrt(1.0 + m33 - m11 - m22);
        this._w = (m21 - m12) / s;
        this._x = -(m13 + m31) / s;
        this._y = -(m23 + m32) / s;
        this._z = -0.25 * s;
    }
    this._onChangeCallback();
    return this;
}

const renderer = new THREE.WebGLRenderer({antialias: true}); //THREE.WebGLRenderer({ stencil: true});
renderer.setPixelRatio(window.devicePixelRatio);
renderer.setSize(canvasWidth, canvasHeight); 
renderer.shadowMap.enabled = true;
renderer.shadowMap.type =  THREE.PCFSoftShadowMap; //THREE.PCFShadowMap; //THREE.VSMShadowMap;
renderer.setAnimationLoop(render);
document.body.appendChild(renderer.domElement);

//===Scene===
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x000000);

//===Lights===
const light0 = new THREE.DirectionalLight(0xffffff, 1.0);
light0.position.set(0, 0, 0).normalize();
//light0.position.copy(camera.position);
light0.castShadow = false;
scene.add(light0);

//const light1 = new THREE.AmbientLight(0x808080);
//const light1 = new THREE.PointLight(0xffffff, 3, 0, 0);
//const light1 = new THREE.SpotLight(0x808080, 1.0);
const light1 = new THREE.DirectionalLight(0x808080, 1.0);

light1.position.set(0, 7, 0); //.normalize();
light1.lookAt(scene.position);

const lightTarget = new THREE.Object3D(); 
lightTarget.position.set(0, 0, 0);
light1.target = lightTarget;

light1.castShadow = true;
light1.shadow.radius = 10;
light1.shadow.blurSamples = 1;
light1.shadow.mapSize.width = 512
light1.shadow.mapSize.height = 512;

//---for DirectionalLight (OrthographicCamera)---
light1.shadow.camera.left = -10; //-5;
light1.shadow.camera.right = 10; //5;
light1.shadow.camera.top = 10; //5;
light1.shadow.camera.bottom = -10; //-5;
light1.shadow.bias = -0.0;
//---for PointLight or SpotLight (PerspectiveCamera)---
light1.shadow.camera.fov = 60; //90;
light1.shadow.camera.aspect = 1; //1;
light1.shadow.camera.near = 0.1; //0.5;
light1.shadow.camera.far = 7; //500;

//light1.shadow.camera.lookAt(scene.position);
//light1.shadow.needsUpdate = true;
//light1.shadow.camera.updateProjectionMatrix();
//light1.shadow.updateMatrices(light1);

scene.add(light1);
//scene.add(lightTarget);

//scene.traverse((child) => {if(child.material) child.material.needsUpdate=true});

//===Light camera helper===
//const helper = new THREE.CameraHelper(light1.shadow.camera);
//scene.add(helper);

//===Grid helper===
//const gridHelper = new THREE.GridHelper(32, 16);
//scene.add(gridHelper);

//===Camera===
var camRadius = 8;
const camAngleDown = new THREE.Vector3();
const camAngle = new THREE.Vector3();
camAngle.x = -45;
camAngle.y = 45;
camAngle.z = 45;
const camera = new THREE.PerspectiveCamera(90, canvasWidth / canvasHeight, 0.1, 1000);
//const camera = new THREE.OrthographicCamera(10 / - 2, 10 / 2, 10 / 2, 10 / - 2, 1, 1000);
//camera.aspect = canvasWidth / canvasHeight; 
camera.updateProjectionMatrix();
function cameraPositionUpdate() {
	camera.position.x = camRadius * Math.sin(toRad(camAngle.x)) * Math.cos(toRad(camAngle.y));
	camera.position.z = camRadius * Math.cos(toRad(camAngle.x)) * Math.cos(toRad(camAngle.y));
	camera.position.y = camRadius * Math.sin(toRad(camAngle.y));
	light0.position.set(camera.position.x, camera.position.y, camera.position.z).normalize();
	camera.lookAt(scene.position);
}
cameraPositionUpdate();

//===Sphere===
const sphereGeometry = new THREE.SphereGeometry(40, 32, 16);
//clipMaterial = new THREE.MeshBasicMaterial({
sphereMaterial = new THREE.MeshPhongMaterial({
	color: 0x000040,
	shininess: 100,
	side: THREE.DoubleSide,
});
const sphere = new THREE.Mesh(sphereGeometry, sphereMaterial);
scene.add(sphere);

//===SVG===
const svgPath0 = 'M978 316c8,1 14,8 14,17l0 102c0,5 -3,9 -7,9l-4 1c0,0 -1,0 -1,0 -2,0 -4,-1 -5,-2 -1,-1 -2,-3 -2,-5l0 -1 -270 38c-54,0 -109,0 -163,0 -2,15 -3,31 -5,47l-23 175 119 22c0,-1 0,-4 2,-4 5,0 10,5 10,11l0 64c0,3 -2,6 -5,6l-3 0c-3,0 -3,-1 -4,-4l-113 16 -16 -36 -1 6c0,1 0,2 -1,2l-3 82c0,2 -2,3 -3,3 -2,0 -3,-1 -3,-3l-2 -82c0,-1 -1,-2 -1,-3l-1 -4 -16 34 -113 -16c0,1 -1,2 -1,3 -1,1 -2,1 -4,1 0,0 -1,0 -1,0l-3 0c-3,0 -5,-3 -5,-6l0 -64c0,-6 4,-11 10,-11l0 0c2,0 4,2 4,4l119 -22 -23 -188c-1,-11 -2,-23 -3,-34l-168 0 -270 -38 0 1c0,2 -1,4 -2,5 -1,1 -3,2 -5,2 0,0 -1,0 -1,0l-4 -1c-4,-1 -7,-5 -7,-9l0 -102c0,-9 6,-17 14,-17 3,0 6,2 6,5l0 4 268 -18 162 0c0,-13 1,-26 2,-38l5 -69c0,-10 9,-17 18,-17l10 0 0 -3 -2 0c-1,0 -2,0 -2,-1 0,-1 0,-2 0,-2l5 -9 -6 0c-2,0 -3,-1 -3,-2l-79 0 0 -3 79 0c1,-1 2,-2 3,-2l10 0 8 -11c1,-1 3,-1 4,0l6 11 10 0c2,0 3,1 3,2l79 0 0 3 -79 0c-1,1 -2,2 -3,2l-5 0 5 9c0,1 0,2 0,2 0,1 -1,1 -2,1l-2 0 0 3 10 0c10,0 18,8 19,17l5 71c1,12 1,25 2,36l164 0 268 18 0 -4c0,-3 3,-5 6,-5z';
const svgPath1 = 'M500 1c-53,0 -52,150 -53,182 -2,36 -4,81 -5,134 -19,14 -50,38 -87,66l0 -41c0,-10 -8,-19 -19,-19l-7 0c-10,0 -19,9 -19,19l0 75c-22,17 -45,35 -68,52l0 -37c0,-10 -8,-19 -19,-19l-7 0c-10,0 -19,8 -19,19l0 72c-74,57 -136,107 -144,118 0,0 -9,35 -7,46 1,11 10,9 18,0 5,-5 100,-47 184,-84l0 2c0,4 3,8 8,8l3 0c4,0 8,-3 8,-8l0 -10c9,-4 18,-8 26,-12l0 2c0,4 3,8 8,8l3 0c4,0 8,-3 8,-8l0 -10c8,-4 16,-7 22,-10l0 2c0,4 3,8 8,8l3 0c4,0 8,-3 8,-8l0 -10c14,-6 23,-10 24,-10 2,-1 6,-2 12,-3l0 4c0,8 6,14 14,14l6 0c8,0 14,-6 14,-14l0 -12c8,-2 15,-3 20,-4 1,56 2,118 5,185 0,0 4,56 13,118l-151 116c0,0 -31,51 -11,55 0,0 89,-35 103,-39 10,-3 57,-21 80,-30 1,4 2,8 4,12 4,19 8,34 8,34l4 0 0 27c0,3 3,6 6,6 3,0 6,-3 6,-6l0 -27 4 0c0,0 4,-15 8,-34 1,-4 3,-8 4,-12 22,9 69,27 80,30 13,4 103,39 103,39 20,-4 -11,-55 -11,-55l-151 -116c9,-62 13,-118 13,-118 3,-67 4,-129 5,-185 5,1 12,3 20,4l0 12c0,8 6,14 14,14l6 0c8,0 14,-6 14,-14l0 -4c6,1 10,3 12,3 1,1 10,4 24,10l0 10c0,4 3,8 8,8l3 0c4,0 8,-3 8,-8l0 -2c7,3 14,6 22,10l0 10c0,4 3,8 8,8l3 0c4,0 8,-3 8,-8l0 -2c8,4 17,8 26,12l0 10c0,4 3,8 8,8l3 0c4,0 8,-3 8,-8l0 -2c84,37 179,79 184,84 9,9 17,11 18,0 1,-11 -7,-46 -7,-46 -8,-11 -70,-61 -144,-118l0 -72c0,-10 -8,-19 -19,-19l-7 0c-10,0 -19,8 -19,19l0 37c-23,-18 -46,-35 -68,-52l0 -75c0,-10 -8,-19 -19,-19l-7 0c-10,0 -19,8 -19,19l0 41c-37,-28 -68,-52 -87,-66 -1,-53 -3,-98 -5,-134 -1,-29 0,-182 -53,-182z';
const svgPath2 = "M797 673l-227 -174 10 -197 -37 0c-5,-132 -21,-242 -43,-302 -22,59 -38,170 -43,302l-37 0 10 197 -227 174 -37 -127 0 318 19 -34 259 -41 2 43 -106 136 14 32 111 -58 35 45 35 -45 111 58 14 -32 -106 -136 2 -43 259 41 19 34 0 -318 -37 127z"
//const svgCode = '<svg viewBox="0 0 11100 8000"><path d="M10893 1895c86,6 153,90 153,190l0 1125c0,52 -33,96 -78,103l-47 8c-4,1 -8,1 -13,1 -20,0 -40,-8 -54,-23 -15,-15 -23,-34 -23,-55l0 -11 -2975 418c-1,0 1,0 0,0l-1798 0c-17,170 -37,343 -60,515l-252 1926 1311 238c23,4 -2,-41 21,-41 60,1 111,57 111,123l0 704c0,35 -24,64 -56,69l-32 5c-30,5 -36,-15 -42,-43l-1242 174 -180 -391 -8 64c-1,9 -4,17 -8,25l-37 900c-1,20 -17,35 -36,35 -20,0 -36,-16 -36,-35l-25 -898c-5,-9 -8,-18 -9,-28l-6 -49 -174 377 -1242 -174c-2,11 -8,21 -16,29 -11,10 -25,15 -39,15 -3,0 -6,0 -9,-1l-32 -5c-32,-5 -57,-35 -57,-69l0 -704c0,-65 48,-119 108,-123l3 0c24,0 43,18 43,41l0 0 1311 -238 -250 -2069c-14,-126 -27,-251 -38,-372l-1844 0 -2975 -418 0 11c0,21 -8,41 -23,55 -15,15 -34,23 -54,23 -4,0 -8,0 -13,-1l-47 -8c-45,-8 -78,-51 -78,-103l0 -1125c0,-100 67,-183 153,-190 33,-3 62,24 62,58l0 40 2947 -193 1780 0c5,-141 12,-282 22,-423l51 -759c5,-106 99,-191 203,-191l110 0 0 -30 -22 0c-9,0 -17,-5 -21,-13 -4,-8 -4,-17 1,-25l57 -94 -62 0c-17,0 -31,-11 -37,-26l-873 0 0 -29 873 0c6,-15 20,-26 37,-26l111 0 87 -120c9,-15 33,-15 42,0l70 119 107 0c17,0 31,11 37,26l873 0 0 29 -873 0c-6,15 -20,26 -37,26l-59 0 55 94c5,8 5,17 0,25 -4,8 -12,12 -21,12l-23 0 0 30 115 0c107,0 197,84 204,192l50 784c9,136 15,270 20,398l1801 0 2947 193 0 -40c0,-33 29,-60 62,-58z"/></svg>';
//const svgContainer = document.getElementById('svg-container');
//svgContainer.innerHTML = svgCode;

function svgPathToShape(s) {
	const shape = new THREE.Shape();
	shape.autoClose = true;

    function nextFloatPos(str, pos) {
		var n = pos;
		while (((str.charAt(n) >= '0') && (str.charAt(n) <= '9')) || (str.charAt(n) == '-') || (str.charAt(n) == '.')) n++;
		return n;
	}
    
	const point = new THREE.Vector2();
    var prevChar = ' ';
    var thisChar = ' ';
	var	i = 0;	
	while (i < s.length) {
		thisChar = s.charAt(i);
		if (thisChar == ' ') thisChar = prevChar;
		i++;
		switch (thisChar) {
			case 'M':
    			prevChar = thisChar;
    			n = nextFloatPos(s, i);
    			x = parseFloat(s.substring(i, n));
    			i = n + 1;
    			n = nextFloatPos(s, i);
    			y = parseFloat(s.substring(i, n));
    			i = n;
				point.x = x;
				point.y = y;
				shape.moveTo(point.x, point.y);
				break;
			case 'l':
    			prevChar = thisChar;
    			n = nextFloatPos(s, i);
    			x = parseFloat(s.substring(i, n));
    			i = n + 1;
    			n = nextFloatPos(s, i);
    			y = parseFloat(s.substring(i, n));
    			i = n;
				point.x += x;
				point.y += y;
				shape.lineTo(point.x, point.y);
    			break;
			case 'c':
    			prevChar = thisChar;
    			n = nextFloatPos(s, i);
    			x1 = parseFloat(s.substring(i, n));
    			i = n + 1;
    			n = nextFloatPos(s, i);
    			y1 = parseFloat(s.substring(i, n));
    			i = n + 1;
    			n = nextFloatPos(s, i);
    			x2 = parseFloat(s.substring(i, n));
    			i = n + 1;
    			n = nextFloatPos(s, i);
    			y2 = parseFloat(s.substring(i, n));
    			i = n + 1;
    			n = nextFloatPos(s, i);
    			x = parseFloat(s.substring(i, n));
    			i = n + 1;
    			n = nextFloatPos(s, i);
    			y = parseFloat(s.substring(i, n));
    			i = n;
				point.x += x;
				point.y += y;
				shape.bezierCurveTo(
					shape.currentPoint.x + x1,
					shape.currentPoint.y + y1,
					shape.currentPoint.x + x2,
					shape.currentPoint.y + y2,
					shape.currentPoint.x + x,
					shape.currentPoint.y + y
				);
				break;
			case 'z':
				i = s.length;
				break;
			default:
				i++;
		}
	}
	return shape;
}

//===Plane===
const planeExtrudeSettings = {
	steps: 8,
	depth: 50.0,
	bevelEnabled: true,
	bevelSize: 0.2,
	bevelSegments: 8,
	bevelThickness: 0.2,
	bevelOffset: 0
};

const plane = [];

const plane0Shape = svgPathToShape(svgPath0);
const plane0Geometry = new THREE.ExtrudeGeometry(plane0Shape, planeExtrudeSettings);
plane0Geometry.center();
const plane0Material = new THREE.MeshLambertMaterial({color: 0xC0C080, wireframe: false});
const plane0Mesh = new THREE.Mesh(plane0Geometry, plane0Material)
plane0Mesh.rotation.set(Math.PI / 2, 0, Math.PI / 2);
plane0Mesh.castShadow = true;
plane0Mesh.scale.set(0.001, 0.001, 0.001);
const plane0 = new THREE.Group();
plane0.add(plane0Mesh);
plane.push(plane0);
scene.add(plane[0]);

const plane1Shape = svgPathToShape(svgPath1);
const plane1Geometry = new THREE.ExtrudeGeometry(plane1Shape, planeExtrudeSettings);
plane1Geometry.center();
const plane1Material = new THREE.MeshLambertMaterial({color: 0x80C0C0, wireframe: false});
const plane1Mesh = new THREE.Mesh(plane1Geometry, plane1Material)
plane1Mesh.rotation.set(Math.PI / 2, 0, Math.PI / 2);
plane1Mesh.castShadow = true;
plane1Mesh.scale.set(0.002, 0.002, 0.002);
const plane1 = new THREE.Group();
plane1.add(plane1Mesh);
plane.push(plane1);
scene.add(plane[1]);

const plane2Shape = svgPathToShape(svgPath2);
const plane2Geometry = new THREE.ExtrudeGeometry(plane2Shape, planeExtrudeSettings);
plane2Geometry.center();
const plane2Material = new THREE.MeshLambertMaterial({color: 0xC080C0, wireframe: false});
const plane2Mesh = new THREE.Mesh(plane2Geometry, plane2Material)
plane2Mesh.rotation.set(Math.PI / 2, 0, Math.PI / 2);
plane2Mesh.castShadow = true;
plane2Mesh.scale.set(0.0015, 0.0015, 0.0015);
const plane2 = new THREE.Group();
plane2.add(plane2Mesh);
plane.push(plane2);
scene.add(plane[2]);

function FlightData(radius, angle, posX, posY, altitude, velocity, yaw, pitch, roll) {
	this.radius = radius;
	this.angle = angle;
	this.posX = posX;
	this.posY = posY;
	this.altitude = altitude;
	this.velocity = velocity;
	this.yaw = yaw;
	this.pitch = pitch;
	this.roll = roll;
}

flightData = [];

flightData.push(new FlightData(4.0,  0.0, 0.0, 0.0, 0.5, 250.0, 0.0, 0.0, -30.0)); //Private
flightData.push(new FlightData(5.0,  0.0, 0.0, 0.0, 1.5, 300.0, 0.0, 0.0, 0.0)); //Passenger
flightData.push(new FlightData(10.0, 0.0, 0.0, 0.0, 2.5, 500.0, 0.0, 0.0, -20.0)); //Fighter

//u˙=X/m−g⋅sin(θ)+r⋅v−q⋅w
//v˙=y/m−g⋅sin(ϕ)⋅cos(θ)−r⋅u+p⋅w
//w˙=Z/m−g⋅cos(ϕ) cos(θ)−q⋅u−p⋅v

function planeGetNextPosition(x, y, z, pitch, roll, yaw, dist) {
    let matrix = new THREE.Matrix4().makeRotationFromEuler(new THREE.Euler(toRad(pitch), toRad(roll), toRad(yaw), 'XYZ'));
    let moveVector = new THREE.Vector3(0, 0, -dist);
    moveVector.applyMatrix4(matrix);
    let position = new THREE.Vector3(z, y, x).add(moveVector);
    return [position.x, position.y, position.z]
}

function planePositionUpdateNew(index) {
}

function planePositionUpdate(index) {
//	let pos = planeGetNextPosition(1, 2, 3, 10, 20, 30,  5);
	
	plane[index].position.x = flightData[index].radius * Math.sin(toRad(flightData[index].angle)) * Math.cos(toRad(flightData[index].angle));
	plane[index].position.z = flightData[index].radius * Math.cos(toRad(flightData[index].angle)) * Math.cos(toRad(flightData[index].angle)) - flightData[index].radius / 2;
	
	flightData[index].altitude += flightData[index].pitch / 1000;
	plane[index].position.y = flightData[index].altitude;

    plane[index].rotation.x = 0.0;
    plane[index].rotation.y = 0.0;
    plane[index].rotation.z = 0.0;

    plane[index].rotateOnWorldAxis(zAxis, toRad(flightData[index].pitch));
    plane[index].rotateOnWorldAxis(xAxis, toRad(flightData[index].roll));
    plane[index].rotateOnWorldAxis(yAxis, toRad(flightData[index].angle * 2)); //yaw
}

//===Runway===
const runwayStartLineWidth = 0.03;
const runwayStartLineLength = 0.4;
const runwayBorderLineWidth = 0.01;
const runwayBorderLineLength = 0.5;

const runwayFloorMaterial = new THREE.MeshLambertMaterial({color: 0x404040});
const runwayBaseMaterial = new THREE.MeshLambertMaterial({color: 0x101010});
const runwayLineMaterial = new THREE.MeshLambertMaterial({color: 0xC0C0C0});
const runwayLightMaterial = new THREE.MeshBasicMaterial({color: 0xFFFF80, transparent: false, opacity: 1.0});
const runwayDarkMaterial = new THREE.MeshBasicMaterial({color: 0xFFFF80, transparent: true, opacity: 0.1});

const runwayFloorGeometry = new THREE.BoxGeometry(0.5, 1.4, 0.002);
const runwayBaseGeometry = new THREE.BoxGeometry(0.5, 1, 0.002);
const runwayStartLineGeometry = new THREE.BoxGeometry(runwayStartLineWidth, runwayStartLineLength, 0.001);
const runwayBorderLineGeometry = new THREE.BoxGeometry(runwayBorderLineWidth, runwayBorderLineLength, 0.001);
const runwayLightGeometry = new THREE.SphereGeometry(0.02, 16, 16);

const runwayFloor = new THREE.Mesh(runwayFloorGeometry, runwayFloorMaterial);
runwayFloor.rotation.x = Math.PI / 2;
runwayFloor.position.y = 0.002;
runwayFloor.receiveShadow = true;
const runwayBase = new THREE.Mesh(runwayBaseGeometry, runwayBaseMaterial);
runwayBase.rotation.x = Math.PI / 2;
runwayBase.position.y = 0.004;
runwayBase.receiveShadow = true;
const runwayBorderLine = new THREE.Mesh(runwayBorderLineGeometry, runwayLineMaterial);
runwayBorderLine.rotation.x = Math.PI / 2;
runwayBorderLine.rotation.z = Math.PI / 2;
runwayBorderLine.position.y = 0.006;
runwayBorderLine.receiveShadow = true;
const runwayStartLine = new THREE.Mesh(runwayStartLineGeometry, runwayLineMaterial);
runwayStartLine.rotation.x = Math.PI / 2;
runwayStartLine.rotation.z = Math.PI / 2;
runwayStartLine.position.y = 0.006;
runwayStartLine.receiveShadow = true;

const runwayLight0 = new THREE.Mesh(runwayLightGeometry, runwayLightMaterial);
runwayLight0.position.z = 0.025;
const runwayLight1 = new THREE.Mesh(runwayLightGeometry, runwayLightMaterial);
runwayLight1.position.z = 0.6;
const runwayLight2 = new THREE.Mesh(runwayLightGeometry, runwayLightMaterial);
runwayLight2.position.z = -0.6;

const runwayElement = []; //new THREE.Group();

runwayElement.push(new THREE.Group());

runwayElement[0].add(runwayLight0.clone());
runwayElement[0].add(runwayLight1.clone());
runwayElement[0].add(runwayLight2.clone());
runwayElement[0].add(runwayFloor.clone());
runwayElement[0].add(runwayBase.clone());
runwayBorderLine.position.z = 0.45;
runwayElement[0].add(runwayBorderLine.clone());
runwayBorderLine.position.z = -0.45;
runwayElement[0].add(runwayBorderLine.clone());
for (let i = 0; i < 6; i++) {
	runwayStartLine.position.z = 0.35 - i * runwayStartLineWidth * 2;
	runwayElement[0].add(runwayStartLine.clone());
	runwayStartLine.position.z = -0.35 + i * runwayStartLineWidth * 2;
	runwayElement[0].add(runwayStartLine.clone());
}

runwayElement.push(new THREE.Group());
runwayElement[1].add(runwayLight0.clone());
runwayElement[1].add(runwayLight1.clone());
runwayElement[1].add(runwayLight2.clone());
runwayElement[1].add(runwayFloor.clone());
runwayElement[1].add(runwayBase.clone());
runwayBorderLine.position.z = 0.45;
runwayElement[1].add(runwayBorderLine.clone());
runwayBorderLine.position.z = -0.45;
runwayElement[1].add(runwayBorderLine.clone());

runwayElement.push(new THREE.Group());
runwayElement[2].add(runwayLight0.clone());
runwayElement[2].add(runwayLight1.clone());
runwayElement[2].add(runwayLight2.clone());
runwayElement[2].add(runwayFloor);
runwayElement[2].add(runwayBase);
runwayBorderLine.position.z = 0.45;
runwayElement[2].add(runwayBorderLine.clone());
runwayBorderLine.position.z = 0.0;
runwayElement[2].add(runwayBorderLine.clone());
runwayBorderLine.position.z = -0.45;
runwayElement[2].add(runwayBorderLine.clone());
runwayElement[2].position.x = 1;

//const runway = [];
//runway.push(new THREE.Group());
const runway = new THREE.Group();

const runwayLength = 8;
var posX = -runwayLength - 1;
runwayElement[0].position.x = posX++ / 2;
runway.add(runwayElement[0].clone());
for (let i = 0; i < runwayLength; i++) {
	runwayElement[1].position.x = posX++ / 2;
	runway.add(runwayElement[1].clone());
	runwayElement[2].position.x = posX++ / 2;
	runway.add(runwayElement[2].clone());
}
runwayElement[1].position.x = posX++ / 2;
runway.add(runwayElement[1].clone());
runwayElement[0].position.x = posX++ / 2;
runway.add(runwayElement[0].clone());
scene.add(runway);

//===Field===
const fieldWidth = 18;
const fieldHeight = 10;
const fieldMaterial0 = new THREE.MeshLambertMaterial({color: 0x009000});
const fieldMaterial1 = new THREE.MeshLambertMaterial({color: 0x007000});
const fieldGeometry = new THREE.BoxGeometry(1, 1, 0.002);
const fieldMesh0 = new THREE.Mesh(fieldGeometry, fieldMaterial0);
const fieldMesh1 = new THREE.Mesh(fieldGeometry, fieldMaterial1);
const field = [];
for (let i = 0; i < fieldWidth * fieldHeight; i++) {
  if ((i & 1) == (~~(i / fieldWidth) & 1)) {
  	field.push(fieldMesh0.clone());
  } else {
  	field.push(fieldMesh1.clone());
  }
  field[i].receiveShadow = true;
  field[i].rotation.x = Math.PI / 2;
  field[i].position.x = (i % fieldWidth) - (fieldWidth / 2) + 0.5;
  field[i].position.z = ~~(i / fieldWidth) - (fieldHeight / 2) + 0.5;
  scene.add(field[i]);
}

//===Star===
const starExtrudeSettings = {
	steps: 8,
	depth: 0.1,
	bevelEnabled: true,
	bevelThickness: 0.2,
	bevelSize: 0.4,
	bevelSegments: 163
//	extrudePath: randomSpline
};
const starPoints = [];
const starPointsCount = 5;

for (let i = 0; i < starPointsCount * 2; i++) {
	const n = i % 2 == 1 ? 1 : 2;
	const a = i / starPointsCount * Math.PI;
	starPoints.push(new THREE.Vector2(Math.cos(a) * n, Math.sin(a) * n));
}

const starVertices = new Float32Array(starPointsCount * 2 * 3 * 3);
for (let i = 0; i < starPointsCount * 2; i++) {
	const n1 = i % 2 == 1 ? 1 : 2;
	const n2 = i % 2 == 1 ? 2 : 1;
	const a1 = (i + 0) / starPointsCount * Math.PI;
	const a2 = (i + 1) / starPointsCount * Math.PI;
	const m = i * 9;
	starVertices[m + 0] = 0;
	starVertices[m + 1] = 0;
	starVertices[m + 2] = 0;
	starVertices[m + 3] = Math.cos(a1) * n1;
	starVertices[m + 4] = Math.sin(a1) * n1;
	starVertices[m + 5] = 0.5;
	starVertices[m + 6] = Math.cos(a2) * n2;
	starVertices[m + 7] = Math.sin(a2) * n2;
	starVertices[m + 8] = 0.5;
}

const vertices = starVertices.length / 3; // Assuming 3 components (x, y, z) per vertex
const starColors = new Float32Array(vertices * 3); // 3 components for RGB

// Populate colors array (e.g., make all vertices red)
for (let i = 0; i < vertices; i++) {
    const n = i % 2 == 1 ? 0.5 : 1;
    const m = i * 3;
    starColors[m + 0] = n; //Red
    starColors[m + 1] = n / 2; //Green
    starColors[m + 2] = 0.0; //Blue
}

const starGeometry = new THREE.BufferGeometry();
starGeometry.setAttribute('position', new THREE.BufferAttribute(starVertices, 3));
starGeometry.setAttribute('color', new THREE.Float32BufferAttribute(starColors, 3));

//const starGeometry = new THREE.ExtrudeGeometry(geometry, starExtrudeSettings);

//const starShape = new THREE.Shape(starPoints);
//const starGeometry = new THREE.ExtrudeGeometry(starShape, starExtrudeSettings);
const starMaterial = new THREE.MeshBasicMaterial({vertexColors: true, wireframe: false, side:THREE.DoubleSide});
//const starMaterial0 = new THREE.MeshLambertMaterial({color: 0xc00000, wireframe: false});
//const starMaterial1 = new THREE.MeshLambertMaterial({color: 0xff8000, wireframe: false});
//const starMaterials = [starMaterial0, starMaterial1];

const star = new THREE.Mesh(starGeometry, starMaterial);
star.position.y = 0.5;
star.rotation.x = Math.PI / 2;
star.visible = false;
scene.add(star);

//===Line===
//var linePosition = 0;
//const lineMaterial = new THREE.LineBasicMaterial({color: 0xffffff})
//const lineGeometry = new THREE.BufferGeometry();
//const linePositionAttribute = new THREE.BufferAttribute(new Float32Array(1000 * 3), 3);
//linePositionAttribute.setUsage(THREE.DynamicDrawUsage);
//lineGeometry.setAttribute('position', linePositionAttribute);
//line = new THREE.Line(lineGeometry, lineMaterial);
//scene.add(line);

//-6,  1, 10,
//-1,  1, 10,
//  3,  2,  4,
//  6, 15,  4,
//  6, 18,  4,
// 15, 15,-15,
// 15,  9,-16,
// 17,  6,-16,
// 10,  9,  7,
//  2,  9,  8,
// -4,  8,  7,
// -8,  7,  1,
// -9,  7, -4,
// -6,  6, -9,
//  0,  5,-10,
//  7,  5, -7,
//  7,  5,  0,
//  0,  5,  2,
// -5,  4,  2,
// -7,  4, -5,
// -8,  3, -9,
//-12,  3, -10,
//-15,  2, -7,
//-15,  2, -2,
//-14,  1,  3,
//-11,  1, 10,
//-6,  1, 10

const curvePts = [
  0,  0.1,  0,
  1,  0.1,  0,
  3,  0.1,  0,
  5,  1,  0,
  6,  2,  1,
  7,  3,  2,
  
 -6,  1, 10,
 -1,  1, 10,
  3,  2,  4,
  6, 15,  4,
  6, 18,  4,
 15, 15,-15,
 15,  9,-16,
 17,  6,-16,
 10,  9,  7,
  2,  9,  8,
 -4,  8,  7,
 -8,  7,  1,
 -9,  7, -4,
 -6,  6, -9,
  0,  5,-10,
  7,  5, -7,
  7,  5,  0,
  0,  5,  2,
 -5,  4,  2,
 -7,  4, -5,
 -8,  3, -9,
-12,  3, -10,
-15,  2, -7,
-15,  2, -2,
 -12,  3,  0,
 -10,  2,  0,
 -8,  1,  0,
 -4,  0.1,  0,
 -2,  0.1,  0,
  0,  0.1,  0,
];
const curveVectors = [];
for (let i = 0; i < curvePts.length; i += 3) {
    curveVectors.push(new THREE.Vector3(curvePts[i + 0], curvePts[i + 1], curvePts[i + 2]));
}
const curveSegmentCount = 1500;
const curve = new THREE.CatmullRomCurve3(curveVectors);
const curvePoints = curve.getPoints(curveSegmentCount);
const curveLength = curve.getLength();
const curveLengths = curve.getLengths(curveSegmentCount);

const line = new THREE.LineLoop( new THREE.BufferGeometry().setFromPoints(curvePoints), new THREE.LineBasicMaterial({color: 0x4488cc}));
scene.add(line);

let tangent = 0;
const normal = new THREE.Vector3();
const binormal = new THREE.Vector3(0, 1, 0);

const tVectors = []; //tangents
const nVectors = []; //normals
const bVectors = []; //binormals
for (let i = 0; i < curveSegmentCount + 1; i ++ ) {
    tangent = curve.getTangent(i / curveSegmentCount);
    tVectors.push(tangent.clone());
    
    normal.crossVectors(tangent, binormal);
	normal.y = 0;
	normal.normalize( );
    nVectors.push(normal.clone());
    
    binormal.crossVectors(normal, tangent);
    bVectors.push(binormal.clone());    
}

//===Raycaster===
raycaster = new THREE.Raycaster();

//===Event listeners===
var isPause = false;

var isKeyCtrl = false;
var isKeySpace = false;
var isKeyLeft = false;
var isKeyUp = false;
var isKeyRight = false;
var isKeyDown = false;

document.addEventListener('keydown', function(event) {
    if ((event.ctrlKey) && (event.keyCode === 187 || event.keyCode === 189)) { // Ctrl + Plus/Minus
		event.preventDefault();
    }
	switch (event.keyCode) {
		case 17: isKeyCtrl = true; break; //Ctrl
		case 32: isKeySpace = true; isPause = !isPause; break; //Space
		case 37: isKeyLeft = true; break; //ArrowLeft
		case 38: isKeyUp = true; break; //ArrowUp
		case 39: isKeyRight = true; break; //ArrowRight
		case 40: isKeyDown = true; break; //ArrowDown
	}
});

document.addEventListener('keyup', function(event) {
	switch (event.keyCode) {
		case 17: isKeyCtrl = false;	break; //Ctrl
		case 32: isKeySpace = false; break; //Space
		case 37: isKeyLeft = false;	break; //ArrowLeft
		case 38: isKeyUp = false; break; //ArrowUp
		case 39: isKeyRight = false; break; //ArrowRight
		case 40: isKeyDown = false;	break; //ArrowDown
	}
});

const pointer = new THREE.Vector2();
const pointerDown = new THREE.Vector2();
const pointerPrev = new THREE.Vector2();
var isPointerDown = false;

document.addEventListener('pointerdown', onPointerDown);
function onPointerDown(event) {
	pointerDown.x = (event.clientX / canvasWidth ) * 2 - 1;
	pointerDown.y = -(event.clientY / canvasHeight ) * 2 + 1;
	pointerPrev.x = pointerDown.x;
	pointerPrev.y = pointerDown.y;
	camAngleDown.x = camAngle.x;
	camAngleDown.y = camAngle.y;
	camAngleDown.z = camAngle.z;
	if (event.ctrlKey) {
		const positionAttribute = line.geometry.getAttribute('position');
		positionAttribute.setXYZ(linePosition, pointerDown.x, pointerDown.y, 0);
		positionAttribute.needsUpdate = true;
		linePosition++;
	}	
	isPointerDown = true;
}

document.addEventListener('pointerup', onPointerUp);
document.addEventListener('pointercancel', onPointerUp);
function onPointerUp(event) {
	linePosition = 0;
	isPointerDown = false;
}

document.addEventListener('pointermove', onPointerMove);
function onPointerMove(event) {
	pointerPrev.x = pointer.x;
	pointerPrev.y = pointer.y;
	pointer.x = (event.clientX / canvasWidth ) * 2 - 1;
	pointer.y = -(event.clientY / canvasHeight ) * 2 + 1;
	if (isPointerDown) {
		if (event.ctrlKey) {
	  		const positionAttribute = line.geometry.getAttribute('position');
	  		positionAttribute.setXYZ(linePosition, pointer.x, pointer.y, 0);
			positionAttribute.needsUpdate = true;
			line.geometry.setDrawRange(0, linePosition);
			linePosition++;
		} else {
			var scale = 180;
			camAngle.x = camAngleDown.x - (pointer.x-pointerDown.x) * scale; if (camAngle.x < 0) camAngle.x += 360; if (camAngle.x > 360) camAngle.x -= 360;
			camAngle.y = camAngleDown.y - (pointer.y-pointerDown.y) * scale; if (camAngle.y < 0) camAngle.y = 0; if (camAngle.y > 90) camAngle.y = 90;
			cameraPositionUpdate();
			raycaster.setFromCamera(pointer, camera);
		}
	}	
}

document.addEventListener('mousewheel', onMouseWheel, {passive: false});
function onMouseWheel(event) {
	if (event.ctrlKey) {
        event.preventDefault();
    }
	if (event.altKey) {
//		camRadius += event.wheelDelta / 100; if (camRadius < 1) camRadius = 1; if (camRadius > 32) camRadius = 32;
		camera.fov -= event.wheelDelta / 100; if (camera.fov < -120) camera.fov = -120; if (camera.fov > 120) camera.fov = 120;
		camera.updateProjectionMatrix()
	} else {
		camRadius -= event.wheelDelta / 200; if (camRadius < 1) camRadius = 1; if (camRadius > 32) camRadius = 32;
		cameraPositionUpdate();
	}
}

window.addEventListener( 'resize', onWindowResize);
function onWindowResize() {
	canvasWidth = window.innerWidth;
    canvasHeight = window.innerHeight;

	renderer.setPixelRatio(window.devicePixelRatio);
 	renderer.setSize(canvasWidth, canvasHeight);
    renderer.render(scene, camera);

    camera.aspect = canvasWidth / canvasHeight;
    camera.updateProjectionMatrix();
}

//===Renderer===
var thisLight = 0;
var thisMaterial = 0;
var planeIndex = 0;

var ailerons = 0;
var elevators = 0;
var rudder = 0;

var planePos = 0;

function action() {
	if (!isPause) {
		if (!isPointerDown) {
//       		camAngle.x += 0.1;
//				cameraPositionUpdate();
		}

//===Keys===
		if (isKeyLeft) {
			ailerons -= 0.02; if (ailerons < -1) ailerons = -1;
		} else if (isKeyRight) {
			ailerons += 0.02; if (ailerons > 1) ailerons = 1;
		} else {
			if (ailerons > 0) ailerons -= 0.02; else if (ailerons < 0) ailerons += 0.02;
		}

		if (isKeyUp) {
			elevators -= 0.02;  if (elevators < -1) elevators = -1;
		} else if (isKeyDown) {
			elevators += 0.02; if (elevators > 1) elevators = 1;
		} else {
			if (elevators > 0) elevators -= 0.02; else if (elevators < 0) elevators += 0.02;
		}

//===Planes rotation, position===
//===Plane 0===
		planeIndex = 0;
		flightData[planeIndex].angle += 0.5; if (flightData[planeIndex].angle >= 360) flightData[planeIndex].angle -= 360;
		flightData[planeIndex].pitch = Math.sin(toRad(flightData[planeIndex].angle * 4)) * 30;
		planePositionUpdate(planeIndex);

//===Plane 1===
		planeIndex++; //1
//			flightData[planeIndex].angle += 0.25; if (flightData[planeIndex].angle >= 360) flightData[planeIndex].angle -= 360; if (flightData[planeIndex].angle < 0) flightData[planeIndex].angle += 360;
//			flightData[planeIndex].pitch = Math.sin(toRad(flightData[planeIndex].angle * 3)) * 30;
//			planePositionUpdate(planeIndex);

		flightData[planeIndex].roll += ailerons;
		flightData[planeIndex].pitch += elevators;

		plane[planeIndex].position.y = 2;

		plane[planeIndex].rotation.y = 0;
		plane[planeIndex].rotation.z = 0;
		plane[planeIndex].rotation.x = 0;
		plane[planeIndex].rotateOnWorldAxis(zAxis, toRad(flightData[planeIndex].pitch));
		plane[planeIndex].rotateOnWorldAxis(xAxis, toRad(flightData[planeIndex].roll));
		plane[planeIndex].rotateOnWorldAxis(yAxis, toRad(flightData[planeIndex].yaw));

//===Plane 2===
		planeIndex++; //2
//		flightData[planeIndex].angle += 1.0; if (flightData[planeIndex].angle >= 360) flightData[planeIndex].angle -= 360;
//		flightData[planeIndex].pitch = Math.sin(toRad(flightData[planeIndex].angle * 2)) * 30;
//		planePositionUpdate(planeIndex);

		plane[planeIndex].quaternion.setFromBasis(tVectors[planePos], bVectors[planePos], nVectors[planePos]);
		plane[planeIndex].position.set(curvePoints[planePos].x, curvePoints[planePos].y, curvePoints[planePos].z);
		planePos++; if (planePos == curveSegmentCount + 1) planePos = 0;

//===Runway lights===
		if (thisMaterial) {
			runway.children[thisLight].children[0].material = runwayDarkMaterial;
			runway.children[thisLight].children[1].material = runwayDarkMaterial;
			runway.children[thisLight].children[2].material = runwayDarkMaterial;
		} else {
			runway.children[thisLight].children[0].material = runwayLightMaterial;
			runway.children[thisLight].children[1].material = runwayLightMaterial;
			runway.children[thisLight].children[2].material = runwayLightMaterial;
		}
		thisLight++;
		if (thisLight == runway.children.length) {
			thisLight = 0;
			thisMaterial++;
			if (thisMaterial == 2) thisMaterial = 0;
		}
//			runway.rotation.y -= Math.PI / 360;
	}
}

var render = function() {
    setTimeout(function() {
        requestAnimationFrame(render);
		action();
	}, 1000 / 60);
    renderer.render(scene, camera);
}

render();

//=========

//u˙=X/m−g⋅sin(θ)+r⋅v−q⋅w
//v˙=y/m−g⋅sin(ϕ)⋅cos(θ)−r⋅u+p⋅w
//w˙=Z/m−g⋅cos(ϕ) cos(θ)−q⋅u−p⋅v

//const planeShape = new THREE.Shape();
//planeShape.moveTo(-0.3, -2);
//planeShape.lineTo(-0.2, -2.7);
//planeShape.lineTo(-1.8, -4);
//planeShape.lineTo(-2, -4.5);
//planeShape.lineTo(-0.1, -3.7);
//planeShape.lineTo(0, -5);
//planeShape.lineTo(0.1, -3.7);
//planeShape.lineTo(2, -4.5);
//planeShape.lineTo(1.8, -4);
//planeShape.lineTo(0.2, -2.7);
//planeShape.lineTo(0.3, -2);
//planeShape.lineTo(0.3, 0);
//planeShape.lineTo(0.5, 0);

//planeShape.lineTo(0.5, 0.5);
//planeShape.lineTo(1.3, 0.3);
//planeShape.lineTo(5.1, -1.3);
//planeShape.lineTo(5, -0.7);
//planeShape.lineTo(0.5, 2.7);

//planeShape.lineTo(0.5, 3);
//planeShape.lineTo(0.3, 3);
//planeShape.lineTo(0.3, 4);
//planeShape.bezierCurveTo(0.3, 4, 0.3, 5, 0, 5);
//planeShape.bezierCurveTo(0, 5, -0.3, 5, -0.3, 4);
//planeShape.lineTo(-0.3, 4);
//planeShape.lineTo(-0.3, 3);
//planeShape.lineTo(-0.5, 3);

//planeShape.lineTo(-0.5, 2.7);
//planeShape.lineTo(-5, -0.7);
//planeShape.lineTo(-5.1, -1.3);
//planeShape.lineTo(-1.3, 0.3);
//planeShape.lineTo(-0.5, 0.5);

//planeShape.lineTo(-0.5, 0);
//planeShape.lineTo(-0.3, 0);
//planeShape.lineTo(-0.3, -2);


//////////////////////////////////////////////////
// Logic
//////////////////////////////////////////////////

class Enum 
{
	// приватный конструктор, чтобы никто не создавал экземпляры
	constructor(name, value) {
	  this.#name = name;
	  this.#value = value;
	  Object.freeze(this); // делаем объект константой
	}
  
	to_string() {
	  return this.#name;
	}
  
	valueOf() {
	  return this.#value;
	}
}
  
class AngleUnits extends Enum 
{
	static RADIAN = new AngleUnits("RADIAN", 0);
	static DEGREE = new AngleUnits("DEGREE", 1);
  
	static values() {
	  return [this.RADIAN, this.DEGREE];
	}
}

class Controllers extends Enum 
{
	static GAME_CONTROLLER = new Controllers("GAME_CONTROLLER", 0);
	static EDIT_CONTROLLER = new Controllers("EDIT_CONTROLLER", 1);
	static MENU_CONTROLLER = new Controllers("MENU_CONTROLLER", 2);
	
	static values() {
	  return [this.GAME_CONTROLLER, this.EDIT_CONTROLLER, this.MENU_CONTROLLER];
	}
}

class IncomingDispatcherEventTypes extends Enum 
{
	static MENU_BOX_SELECT = new IncomingDispatcherEventTypes("MENU_BOX_SELECT", 0);
	static MENU_BACK_CLICK = new IncomingDispatcherEventTypes("MENU_BACK_CLICK", 1);		
	static INFO_PANEL_MENU_CLICK = new IncomingDispatcherEventTypes("INFO_PANEL_MENU_CLICK", 2);          
	static INFO_PANEL_PAUSE_SIM_CLICK = new IncomingDispatcherEventTypes("INFO_PANEL_PAUSE_SIM_CLICK", 3);
	static INFO_PANEL_FAST_SIM_CLICK = new IncomingDispatcherEventTypes("INFO_PANEL_FAST_SIM_CLICK", 4);
	static INFO_PANEL_RESTART_CLICK = new IncomingDispatcherEventTypes("INFO_PANEL_RESTART_CLICK", 5);
	static PAUSE_SIMULATION = new IncomingDispatcherEventTypes("PAUSE_SIMULATION", 5);		
	static EDITOR_CORNER_CLICK = new IncomingDispatcherEventTypes("EDITOR_CORNER_CLICK", 6);
	static AIRPORT_DOUBLE_CLICK = new IncomingDispatcherEventTypes("AIRPORT_DOUBLE_CLICK", 7);
	static AIRPORT_KEY_PRESSED = new IncomingDispatcherEventTypes("AIRPORT_KEY_PRESSED", 8);
	static AIRPORT_MOUSE_DOWN = new IncomingDispatcherEventTypes("AIRPORT_MOUSE_DOWN", 9);
	static AIRPORT_MOUSE_MOVE = new IncomingDispatcherEventTypes("AIRPORT_MOUSE_MOVE", 10);
	static AIRPORT_MOUSE_UP = new IncomingDispatcherEventTypes("AIRPORT_MOUSE_UP", 11);		
	static INFO_PANEL_HINT_CLICK = new IncomingDispatcherEventTypes("INFO_PANEL_HINT_CLICK", 12);
	static MENU_LEVEL_SELECT = new IncomingDispatcherEventTypes("MENU_LEVEL_SELECT", 13);		
	static BANNER_BACK_CLICK = new IncomingDispatcherEventTypes("BANNER_BACK_CLICK", 14);
	static BANNER_START_CLICK = new IncomingDispatcherEventTypes("BANNER_START_CLICK", 15);
	static BANNER_RESTART_CLICK = new IncomingDispatcherEventTypes("BANNER_RESTART_CLICK", 16);
	static BANNER_SKIP_LEVEL_CLICK = new IncomingDispatcherEventTypes("BANNER_SKIP_LEVEL_CLICK", 17);
	static INFO_PANEL_INFO_CLICK = new IncomingDispatcherEventTypes("INFO_PANEL_INFO_CLICK", 18);
}

class OutcomingDispatcherEventTypes extends Enum 
{
	static LEVEL_START = new OutcomingDispatcherEventTypes("LEVEL_START", 0);
	static BOX_OPEN = new OutcomingDispatcherEventTypes("BOX_OPEN", 1);
	static BACK_TO_BOXES = new OutcomingDispatcherEventTypes("BACK_TO_BOXES", 2);
	static RESERVED2 = new OutcomingDispatcherEventTypes("RESERVED2", 3);
	static FAST_SIMULATION = new OutcomingDispatcherEventTypes("FAST_SIMULATION", 4);
	static START_LEVEL = new OutcomingDispatcherEventTypes("START_LEVEL", 6);
	static LEVEL_CONFIG_VISIBILITY = new OutcomingDispatcherEventTypes("LEVEL_CONFIG_VISIBILITY", 7);
	static OBJECT_ACTIVATE = new OutcomingDispatcherEventTypes("OBJECT_ACTIVATE", 8);
	static OBJECT_INFO = new OutcomingDispatcherEventTypes("OBJECT_INFO", 9);
	static OBJECT_SELECT = new OutcomingDispatcherEventTypes("OBJECT_SELECT", 10);
	static PATH_CONTINUE = new OutcomingDispatcherEventTypes("PATH_CONTINUE", 11);
	static PATH_FINISH = new OutcomingDispatcherEventTypes("PATH_FINISH", 12);
	static KEY_PRESSED = new OutcomingDispatcherEventTypes("KEY_PRESSED", 13);
	static SHOW_HINTS = new OutcomingDispatcherEventTypes("SHOW_HINTS", 14);
	static NEXT_LEVEL = new OutcomingDispatcherEventTypes("NEXT_LEVEL", 15);
	static RESERVED1 = new OutcomingDispatcherEventTypes("RESERVED1", 16);		
	static PLAY_LEVEL = new OutcomingDispatcherEventTypes("PLAY_LEVEL", 17);
	static DISPLAY_MODE_CHANGED = new OutcomingDispatcherEventTypes("DISPLAY_MODE_CHANGED", 20);
}

class Colors //static, enum
{
	static BLACK = new Colors ("Black", 0x000000);
	static BLUE = new Colors ("Black", 0x0000FF);
	static BROWN = new Colors ("Black", 0x938F0D);
	static GRAY = new Colors ("Black", 0xAAAAAA);
	static GREEN = new Colors ("Black", 0x00FF00);
	static RED = new Colors ("Black", 0xFF0000);
	static SELECTION = new Colors ("Black", 0xF29200);
	static YELLOW = new Colors ("Black", 0xF2F200);
	static WHITE = new Colors ("Black", 0xFFFFFF);
}

///////////////////////////////////////////////////////////
//  Instruments.as
///////////////////////////////////////////////////////////

class Instruments //static
{
	static distDiff(x1, x2, perimeter)//: Number
	{
		var dbl_dist = x1 - x2;
		
		if (Math.abs(dbl_dist) <= perimeter / 2)
			return dbl_dist;
		else
			if (dbl_dist > 0)
				return dbl_dist - perimeter;
			else 
				return dbl_dist + perimeter;
	}

	static random_int(max=Number.MAX_SAFE_INTEGER-1)
	{
		return Math.floor(Math.random() * (max + 1.0))
	}

	static random_sign() //: int
	{
		return Instruments.random_int(3) - 1;  
	}

	static sign(value) //: int
	{
		return value > 0 ? +1 : (value < 0 ? -1 : 0);
	}
	
	static str2bool(str) //: Boolean
	{
		if (str.toUpperCase() === "TRUE")
			return true;
		else
			return false;
	}

	static string_of_char(char, count)
	{
		var str_result = "" 
		var str_char = char.charAt(0);
		for (var i = 1; i <= count; i++)
			str_result += str_char;
		return str_result;
	}
	
	static xor(bool1, bool2) //: Boolean
	{
		return (bool1 != bool2);
	}
}

///////////////////////////////////////////////////////////
//  Angle.as
///////////////////////////////////////////////////////////

class Angle
{
	static #DBL_ROTATION_ERROR = Math.PI /  90;

	#value = 0

	constructor(value, unit=AngleUnits.RADIAN)
	{
		switch(unit)
		{
			case AngleUnits.RADIAN: 
				this.#value = value;
				break;
			case AngleUnits.DEGREE:
				this.#value = value / 180 * Math.PI;
				break;
			default:
				throw new Error("Illegal unit:" + unit.to_string());
		}
		this.normalize();
	} 

// properties
	get DBL_ROTATION_ERROR() 
	{
		return Angle.#DBL_ROTATION_ERROR
	}

	static get HALF_PI() //: Angle
	{
		return new Angle(Math.PI / 2, AngleUnits.RADIAN);
	}

	static get MINUS_HALF_PI() //: Angle
	{
		return new Angle(-Math.PI / 2, AngleUnits.RADIAN);
	}

	static get PI()
	{
		return new Angle(Math.PI, AngleUnits.RADIAN);
	}

	get degree()
    {
    	return this.#value / Math.PI * 180;
    }

    set degree(value)
    {
		this.#value = value / 180 * Math.PI;
		normalize();
    }

    get radian()
    {
    	return this.#value;
    }

	set radian(value)
    {
		this.#value = value;
		normalize();
    }
	
// methods
	// public methods
    abs(angle) //: Angle
    {
		return new Angle(Math.abs(this.radian), AngleUnits.RADIAN);
    }
	
    add(angle) //: Angle
    {
		return new Angle(this.radian + angle.radian, AngleUnits.RADIAN);
    }

	static arcsin(value) //: Angle
	{
		return new Angle(Math.asin(value), AngleUnits.RADIAN);
	}

	static arctg(value) //: Angle
	{
		return new Angle(Math.atan(value), AngleUnits.RADIAN);
	}

    clone() //: Angle
	{
		return new Angle(this.#value, AngleUnits.RADIAN); 
	}

    cos() //: Number
    {
		return Math.cos(this.#value);
    }

    dec(angle)//: void
    {
		this.radian -= angle.radian;
    }
	
	static direction (point_from, point_to, distance_obj = null)
	{
		var x_diff = (point_to.x - point_from.x);		
		var y_diff = -(point_to.y - point_from.y);
		var dbl_dist = Math.sqrt(x_diff*x_diff + y_diff*y_diff);
		var ang_target = Angle.arcsin(x_diff/dbl_dist);  	
		if (y_diff < 0) ang_target.radian = Math.PI - ang_target.radian;
		
		if (distance_obj)
			distance_obj.Distance = dbl_dist;
			
		return ang_target;
	}

	//в какую сторону нужно врущаться с текущего угла в AnAngle 
	//1 - по часовой (в сторону увеличения угла)
	//-1 - против часовой (в сторону уменьшения угла)
	//0 - поворот не требуется
	get_rotation(angle) //: int
	{
		var dbl_ang = this.normalizeAngleValue(angle.radian - this.radian);
		if (Math.abs(dbl_ang) < DBL_ROTATION_ERROR)
			return 0;
		else
			return (dbl_ang > 0) ? 1 : ((dbl_ang < 0) ? -1 : 0);
	}
	
    inc(angle) //: void
    {
		this.radian += angle.radian;
    }

    sin() //: Number
    {
		return Math.sin(this.#value);
    }

    sub(angle)//: Angle
    {
		return new Angle(this.radian - angle.radian, AngleUnits.RADIAN);
    }
	
	to_string(indent=0) //: String
	{
		var str_indent = Instruments.stringOfChar("\t", indent);
		var str_indent_plus = Instruments.stringOfChar("\t", indent + 1);
		
		return str_indent + "[Angle]\n" 
			+ str_indent + "{\n"
			+ str_indent_plus + "degree=" + this.degree + "\n"
			+ str_indent_plus + "radian=" + this.radian + "\n"
			+ str_indent + "}\n";	
	}	
	
	normalize()
	{
		this.#value = Angle.normalizeAngleValue(this.#value);
	}
	
	static normalizeAngleValue(value) //: Number
	{
		let n_sign = Instruments.sign(value);
		value -= Math.floor(Math.abs(value / (2 * Math.PI))) * 2 * Math.PI * n_sign;
		if (Math.abs(value) > Math.PI)
			value = (2 * Math.PI - Math.abs(value)) * n_sign * -1;
		return value;
	}	
}

///////////////////////////////////////////////////////////
//  Point.as
///////////////////////////////////////////////////////////
class Point
{
	#x;
	#y;

	constructor(x, y) 
	{
		this.#x = x
		this.#y = y
	}
		
	//properties	
	get radius()
	{
		return Math.sqrt(this.#x*this.#x + this.#y*this.#y);
	}		
	
	set radius(value)
	{
		from_polar(value, this.theta);
	}		
		
	get theta() //: Angle
	{
		if (this.#y == 0) 
			return new Angle(Math.PI/2 * Instruments.sign(this.#x), AngleUnits.RADIAN);
		else
		{
			var ang_theta = Angle.arctg(-this.#x/this.#y);
			if (this.#y > 0)
			{
				ang_theta.dec(new Angle.PI);
			}
			return ang_theta;
		}
	}
	
	set theta(angle)
	{
		this.from_polar(this.radius, angle);
	}	

	get x() //: Number
	{
		return this.#x;
	}		

	set x(value)
	{
		this.#x = value;
	}		

	get y() //: Number
	{
		return this.#y;
	}		

	set y(value)
	{
		this.#y = value;
	}			

//methods
	add(point) //: Point
	{
		return new Point(this.#x + point.x, this.#y + point.y);
	}

	clone() //: Point
	{
		return new Point(this.#x, this.#y);
	}
	
	from_polar(radius, theta_angle)
	{
		this.#x = radius * theta_angle.sin();
		this.#y = -radius * theta_angle.cos();
	}

	sub(point) //: Point
	{
		return new Point(this.#x - point.x, this.#y - point.y);
	}
	
	to_string(indent=0) //: String
	{
		var str_indent = Instruments.string_of_char("\t", indent);
		return str_indent + "[Point]\n" 
			+ str_indent + "{\n"
			+ Instruments.string_of_char("\t", indent + 1) + "x=" + this.#x + "\n"
			+ Instruments.string_of_char("\t", indent + 1) + "y=" + this.#y + "\n"
			+ str_indent + "}\n";
	}	
}

///////////////////////////////////////////////////////////
//  PointsEventDispatcher.as
///////////////////////////////////////////////////////////
public class PointsEventDispatcher extends EventDispatcher 
{
//public consts
	static ON_ADD() {return "OnAdd"};		
	static ON_REMOVE() {return "OnRemove"};
	
//public methods
	fire_on_add()
	{
		//trace("OnAdd");
		//TODO: event
		//dispatchEvent(new Event(PointsEventDispatcher.ON_ADD));
	}
	
	fire_on_remove()
	{
		//trace("OnRemove");		
		//TODO: event
		//dispatchEvent(new Event(PointsEventDispatcher.ON_REMOVE));
	}
}


///////////////////////////////////////////////////////////
//  Points.as
///////////////////////////////////////////////////////////

class Points
{
//private variables
	#points = []; //: Vector.<Point>;

//properties
	get length () //:uint
	{
		return this.#points.length;
	}

//constructor
	constructor ()
	{
		this.#points = new Vector.<Point>();
		this.on_add  = new PointsEventDispatcher();
		this.on_remove = new PointsEventDispatcher();
	}		

//public methods
	append(point) //: int
	{
		this.#points.push(point);
		this.on_add.fire_on_add();
		return this.#points.length - 1;
	}

	get(index) //: Point
	{
		return this.#points[index];
	}
	
	removeAll()
	{
		this.#points.length = 0;
		this.on_remove.fire_on_remove();
	}	

	removeAt(index_from, count=1) 
	{
		this.#points.splice(index_from, count);
		on_remove.fire_on_remove();		
	}
	
	shift() //: Point	
	{
		return this.#points.shift();
		on_remove.fire_on_remove();
	}	
}

///////////////////////////////////////////////////////////
//  Size.as
///////////////////////////////////////////////////////////

class Size
{
	#height;
	#width;

	constructor(height, width) {
		this.#height = height
		this.#width = width
	}
	
//properties
	get height() //: Number
	{
		return this.#height;
	}
		
	set height(value)
	{
		this.#height = value;
	}
	
	get width() //: Number
	{
		return this.#width;
	}
		
	set width(value)
	{
		this.#width = value;
	}

//methods
	clone() //: Size
	{
		return new Size(this.#width, this.#height);				
	}

	scale(factor)
	{
		return new Size(this.#width*factor, this.#height*factor);				
	}
	
	to_string(indent=0) //: String
	{
		var str_indent = Instruments.string_of_char("\t", indent);
		var str_indent_plus = Instruments.string_of_char("\t", indent + 1);		
		return str_indent + "[Size]\n" 
			+ str_indent + "{\n"
			+ str_indent_plus + "width=" + this.#width + "\n"
			+ str_indent_plus + "height=" + this.#height + "\n"
			+ str_indent + "}\n";
	}	
}

///////////////////////////////////////////////////////////
//  Rect.as
///////////////////////////////////////////////////////////

class Rect 
{
	#extent: Size;
	#location: Point;

    constructor (location=null, extent=null)
    {
		if (!location) location = new Point();
		this.#location = location;
		if (!extent) extent = new Size();
		this.#extent = extent;
    }
//properties
	get center() //: Point 
	{
		return new Point(this.#location.x + this.#extent.width / 2, 
			this.#location.y + this.#extent.height / 2);
	}
	
	get corner_points() //: Vector.<Point>
	{
		var apnt = []
		for (let i_height = 0; i_height <= 1; i_height++)
		{
			for (let i_width = 0; i_width <= 1; i_width++)	
			{
				let pnt_corner: Point = new Point(this.#location.x + this.#extent.width*i_width, 
					this.#location.y + this.#extent.height*i_height); 
				apnt.push(pnt_corner);
			}
		}
		return apnt;
	}
	//properties
    get extent() //: Size
    {
    	return this.#extent;
    }

	set extent(size)
    {
   		this.#extent = size.clone();
    }
	
    get location() //: Point
    {
    	return this.#location;
    }
	
	set location(point)
    {
   		this.#location = point.clone();
    }
	
//methods
	clone() //: Rect
    {
		return new Rect(this.#location.clone(), this.#extent.clone());
    }
	
	is_inside(point) //: Boolean
	{
		return ((point.x > this.#location.x) 
			&& (point.x < this.#location.x + this.#extent.width) 
			&& (point.y > this.#location.y) 
			&& (point.y < this.#location.y + this.#extent.height));
	}
	
	move_to_rect(point) //: Point
	{
		var pnt_result: Point = new Point();
		pnt_result.x = (point.x < this.#location.x) ? this.#location.x : 
			((point.x > this.#location.x + this.#extent.width) ? this.#location.x + this.#extent.width : point.x);
		pnt_result.y = (point.y < this.#location.y) ? this.#location.y : 
			((point.y > this.#location.y + this.#extent.height) ? this.#location.y + this.#extent.height : point.y);
		return pnt_result;
	}

    to_string(indent=0) //: String
    {
		let str_indent = Instruments.string_of_char("\t", indent);
		let str_indent_plus = Instruments.string_of_char("\t", indent + 1);
		return str_indent + "[Rect]\n"
			+ str_indent + "{\n"	
			+ str_indent_plus + "extent=\n" 
			+ this.#extent.to_string(indent + 2)
			+ str_indent_plus + "location=\n" 
			+ this.#location.to_string(indent + 2)
			+ str_indent + "}\n";	
	}
	
	to_xml(xml_node)
	{
		xml_node.@x = this.#location.x;
		xml_node.@y = this.#location.y;
		xml_node.@width = this.#extent.width;
		xml_node.@height = this.#extent.height;
	}	
}


///////////////////////////////////////////////////////////
//  Region.as
///////////////////////////////////////////////////////////

//Rect с location в центре, повернутый на угол Rotation
class Region extends Rect 
{
	#rotation

	constructor (location=null, size=null, rotation=null)
	{
		if (!location) location = new Point();
		if (!size) size = new Size();
		if (!rotation) rotation = new Angle();
		
		super(location, size);
		this.#rotation = rotation;		
	}

//properties
	get center() //: Point
	{
		return this.location.clone();
	}
	
	get corner_points() //: Vector.<Point>
	{
		var apnt = [];
		for (let i_height = -1; i_height <= 1; i_height+=2)
		{
			for (let i_width = -1; i_width <= 1; i_width+=2)	
			{
				let pnt_corner: Point = new Point(this.#extent.width/2*i_width, this.#extent.height/2*i_height); 
				//var ang_fix = new Angle(pnt_corner.Theta.radian - Math.PI / 2 * i_width); 
				pnt_corner.theta = pnt_corner.theta.add(rotation);
				pnt_corner.x += this.location.x;
				pnt_corner.y += this.location.y;
				apnt[(i_width + 1)/2 + i_height + 1] = pnt_corner;
			}
		}
		return apnt;
	}

	get rotation() //: Angle
    {
    	return this.#rotation;
    }

//methods
	clone_region() //: Region
    {
		return new Region(this.location.clone(), this.extent.clone(), this.rotation.clone());
    }	
	
	in_area(point)
    {
		let point = point.sub(this.location);
		let ang_theta = point.theta;
		point.theta = ang_theta.sub(rotation);
		return Math.abs(point.y) < this.extent.height / 2 && Math.abs(point.x) < this.extent.width / 2;
	}

	to_string(indent=0) //: String
	{
		let str_indent = Instruments.string_of_char("\t", indent);
		let str_indent_plus = Instruments.string_of_char("\t", indent + 1);
		return str_indent + "[Region]\n"
			+ str_indent + "{\n"
			+ super.to_string(indent + 1) 
			+ str_indent_plus + "rotation=\n" + this.#rotation.to_string(indent + 2)
			+ str_indent + "}\n";	
	}
}



///////////////////////////////////////////////////////////
//  SelectableObject.as
///////////////////////////////////////////////////////////

//Выделяемый Region с location в центре
class SelectableObject extends Region 
{
    #selected = false;
	
	constructor (location, size, course)
	{
		super(location, size, course);	
	}
	
	static fromXml(xml)
	{
		let x: int = xml.@x;
		let y: int = xml.@y;
		let cx: int = xml.@width;
		let cy: int = xml.@height;
		let n_course: int = xml.@course;

		return new SelectableObject(new Point(x, y), new Size(cx, cy), new Angle(n_course, AngleUnits.DEGREE));
	}

//properties

	get course() //: Angle
    {
    	return this.rotation;
    }

    get selected() //: Boolean
    {
    	return this.#selected;
    }

    set selected(is_selected)
    {
		this.#selected = is_selected;
    }

//methods
	clone_object() //: SelectableObject
    {
		var mo: SelectableObject = new SelectableObject(this.location.clone(), this.extent.clone(), this.course.clone());
		mo.selected = this.#selected;
		return mo;
    }	

	to_string(indent=0) //: String
	{
		let str_indent = Instruments.string_of_char("\t", indent);
		let str_indent_plus = Instruments.string_of_char("\t", indent + 1);
		return str_indent + "[SelectableObject]\n"
			+ str_indent + "{\n"
			+ super.to_string(indent + 1) 
			+ str_indent_plus + "course=\n" + this.course.to_string(indent + 2)
			+ str_indent_plus + "selected=" + this.#selected + "\n"
			+ str_indent + "}\n";	
	}
	
	to_xml(xml_node)
	{
		super.to_xml(xml_node);
		xml_node.@course = this.course.degree;
	}	
}


///////////////////////////////////////////////////////////
//  Cloud.as
///////////////////////////////////////////////////////////

class Cloud extends SelectableObject
{
//public consts
	static get AVG_PROBABILITY() {return 0.0015};
	static get MAX_DENSITY() {return 4};
	static get SNOW_CLOUD_DENSITY() {return 4};

//private consts
	static #SIDE_SPEED = 24;
	
//property fields
	#density = 0;

//properties
	get Density()
	{
		return this.#density;
	}
	
//methods
	//constructor
    constructor(location, size, angle, density)
    {
		this.#density = Math.min(density, Cloud.MAX_DENSITY);
		super(location, size, angle);
    }

	//public methods

    in_area(point)
    {
		return super.in_area(APoint);
	}

    move(wind)
    {
		this.location.x += (wind.horizontal_speed + this.course.sin() * Cloud.#SIDE_SPEED) / Core.FRAME_RATE;
		this.location.y += (wind.vertical_speed - this.course.cos() * Cloud.#SIDE_SPEED) / Core.FRAME_RATE;
	}		
	
	to_string(indent=0) //: String
	{
		var str_indent = Instruments.string_of_char("\t", indent);
		
		return str_indent + "[Cloud]\n" 
			+ str_indent + "{\n"
			+ super.to_string(indent + 1)
			+ str_indent + "}\n";	
	}
}


///////////////////////////////////////////////////////////
//  Wind.as
///////////////////////////////////////////////////////////

class Wind
{
//public consts
	get DBL_MAX_WIND_SPEED() {return 70};

//private consts
	#DBL_ACC = 1; //m/s/s
	#DBL_TURN_RATE = Math.PI / 360; //deg/sec

	//property fields
	#direction = new Angle(); //Куда дует ветер, не откуда!
	#maximal_speed = 0;
	#minimal_speed = 0;	
	#speed = 0;

	//other fields
	#target_direction = new Angle;
	#target_speed = 0;
	#variability = 0; 
	#timeout = new Date(0);
	
//properties
	//Направление в котором дует ветер. Не откуда он дует!
	get direction() //: Angle
	{
		return this.#direction;
	}

	get horizontal_speed() //: Number
	{
		return this.#speed * this.#direction.sin();
	}

	get maximal_speed() //: Number
	{
		return #this.#maximal_speed;
	}
	
	get minimal_speed() //: Number
	{
		return this.#minimal_speed;
	}

	get speed() //: Number
	{
		return this.#speed;
	}
	
	get vertical_speed() //: Number
	{
		return -this.#speed * this.#direction.cos();	
	}


//constructor
	constructor (min_speed, max_speed, variability)
	{
		#this.#maximal_speed = Math.min(max_speed, DBL_MAX_WIND_SPEED);
		this.#minimal_speed = min_speed;
		this.#variability = variability;
		this.update();
		this.#direction.radian = this.#target_direction.radian;
		this.#speed = this.#target_speed;
	}		

	//public methods

	update()
	{
		var dt_now = new Date();
		if (dt_now.time > this.#timeout.time)
		{
			//Timer
			//this.#timeout.setTime((this.#variability > 0) ? dt_now.time + 1000/this.#variability : int.MAX_VALUE);
				
			this.#target_direction.radian = Math.random() * Math.PI * 2;
			this.#target_speed = Math.random() * (this.#maximal_speed - this.#minimal_speed) + this.#minimal_speed;
		}
		this.#direction.radian += this.#direction.get_rotation(this.#target_direction) * this.#DBL_TURN_RATE / Core.FRAME_RATE;
		this.#speed += this.#DBL_ACC / Core.FRAME_RATE * ((this.#speed < this.#target_speed) ? +1 : -1)
		if (this.#speed < 0) this.#speed = 0;
	}
}


///////////////////////////////////////////////////////////
//  AircraftType.as
///////////////////////////////////////////////////////////

class AircraftType //enum
{
	//маневренность
	static #TURN_ANGLE_COPTER() {return new Angle(32, Angle.DEGREE);} //deg  	
	static #TURN_ANGLE_PROP() {return new Angle(16, Angle.DEGREE);} //deg  
	static #TURN_ANGLE_LINER() {return new Angle(16, Angle.DEGREE);} //deg  	
	static #TURN_ANGLE_SUPER() {return new Angle(16, Angle.DEGREE);} //deg  	
	//разгон
	static #ACCELERATION_COPTER() {return 6;} //m/s	
	static #ACCELERATION_PROP() {return 8;} //m/s	
	static #ACCELERATION_LINER() {return 10;} //m/s	
	static #ACCELERATION_SUPER() {return 12;} //m/s		
	//скорость подхода
	static #CRUISE_SPEED_COPTER() {return 220;} //m/s 
	static #CRUISE_SPEED_PROP() {return 270;} //m/s 
	static #CRUISE_SPEED_LINER() {return 320;} //m/s 
	static #CRUISE_SPEED_SUPER() {return 360;} //m/s 	
	//замедление
	static #DECELERATION_COPTER() {return -5;} //m/s	
	static #DECELERATION_PROP() {return -6;} //m/s	
	static #DECELERATION_LINER() {return -7;} //m/s	
	static #DECELERATION_SUPER() {return -8;} //m/s		
	//скорость для отрыва
	static #LIFTOFF_SPEED_COPTER() {return 100;} //m/s	
	static #LIFTOFF_SPEED_PROP() {return 230;} //m/s	
	static #LIFTOFF_SPEED_LINER() {return 280;} //m/s	
	static #LIFTOFF_SPEED_SUPER() {return 330;} //m/s			
	//скорость руления
	static #TAXIING_SPEED_COPTER() {return 120;} //m/s	
	static #TAXIING_SPEED_PROP() {return 140;} //m/s	
	static #TAXIING_SPEED_LINER() {return 150;} //m/s	
	static #TAXIING_SPEED_SUPER() {return 160;} //m/s		
	//скорость при касании
	static #TOUCHDOWN_SPEED_COPTER() {return 100;} //m/s	
	static #TOUCHDOWN_SPEED_PROP() {return 200;} //m/s	
	static #TOUCHDOWN_SPEED_LINER() {return 250;} //m/s	
	static #TOUCHDOWN_SPEED_SUPER() {return 300;} //m/s		
	//разбег (зависимые константы) 
	static #TO_ROLL_RESERVE() {return 300;} //m
	static #TO_ROLL_LENGTH_COPTER() {return (AircraftType.#LIFTOFF_SPEED_COPTER - AircraftType.#TAXIING_SPEED_COPTER) / AircraftType.#ACCELERATION_COPTER 
		* (AircraftType.#LIFTOFF_SPEED_COPTER + AircraftType.#TAXIING_SPEED_COPTER) / 2 + AircraftType.#TO_ROLL_RESERVE;} //m 	
	static #TO_ROLL_LENGTH_PROP() {return (AircraftType.#LIFTOFF_SPEED_PROP - AircraftType.#TAXIING_SPEED_PROP) / AircraftType.#ACCELERATION_PROP 
		* (AircraftType.#LIFTOFF_SPEED_PROP + AircraftType.#TAXIING_SPEED_PROP) / 2 + AircraftType.#TO_ROLL_RESERVE;} //m 	
	static #TO_ROLL_LENGTH_LINER() {return (AircraftType.#LIFTOFF_SPEED_LINER - AircraftType.#TAXIING_SPEED_LINER) / AircraftType.#ACCELERATION_LINER 
		* (AircraftType.#LIFTOFF_SPEED_LINER + AircraftType.#TAXIING_SPEED_LINER) / 2 + AircraftType.#TO_ROLL_RESERVE;} //m 	
	static #TO_ROLL_LENGTH_SUPER() {return (AircraftType.#LIFTOFF_SPEED_SUPER - AircraftType.#TAXIING_SPEED_SUPER) / AircraftType.#ACCELERATION_SUPER 
		* (AircraftType.#LIFTOFF_SPEED_SUPER + AircraftType.#TAXIING_SPEED_SUPER) / 2 + AircraftType.#TO_ROLL_RESERVE;} //m 		
	//пробег
	static #LAND_ROLL_LENGTH_COPTER() {return 1500;} //m	
	static #LAND_ROLL_LENGTH_PROP() {return 2000;} //m	
	static #LAND_ROLL_LENGTH_LINER() {return 3500;} //m/s	
	static #LAND_ROLL_LENGTH_SUPER() {return 5500;} //m/s		
	
	//names
	static #TYPE_COPTER() {return "Coper";}
	static #TYPE_PROPELLER() {return "Propeller";}
	static #TYPE_LINER() {return "Liner";}
	static #TYPE_SUPERSONIC() {return "Supersonic";}

//property fields
	//aircraft types
	static #COPTER = new AircraftType(AircraftType.#TYPE_COPTER);
	static #LINER = new AircraftType(AircraftType.#TYPE_LINER);
	static #PROPELLER = new AircraftType(AircraftType.#TYPE_PROPELLER);	
	static #SUPERSONIC = new AircraftType(AircraftType.#TYPE_SUPERSONIC);
	
	#acceleration = 0;
	#cruise_speed = 0;
	#deceleration = 0;
	#landing_roll_length = 0;
	#liftoff_speed = 0;
	#takeoff_roll_length = 0;
	#taxiing_speed = 0;
	#touchdown_speed = 0;
	#turn_angle = null;
	#type_name = null;

//properties
	static get copter() //: AircraftType
    {
    	return AircraftType.#COPTER;
    }
	
	static get liner() //: AircraftType
    {
    	return AircraftType.#LINER;
    }

	static get propeller() //: AircraftType
    {
    	return AircraftType.#PROPELLER;
    }
	
    static get supersonic() //: AircraftType
    {
    	return AircraftType.#SUPERSONIC;
    }

//state properties
	get acceleration() //: Number
    {
    	return this.#acceleration;
    }
	
	 get cruise_speed() //: Number
    {
    	return this.#cruise_speed;
    }
	
	 get deceleration() //: Number
    {
    	return this.#deceleration;
    }

	 get landing_roll_length() //: Number
    {
    	return this.#landing_roll_length;
    }

	 get liftoff_speed() //: Number
    {
    	return this.#liftoff_speed;
    }
	
	 get takeoff_roll_length()// :Number
    {
    	return this.#takeoff_roll_length;
    }

	 get taxiing_speed()// :Number
    {
    	return this.#taxiing_speed;
    }
	
	 get touchdown_speed()// :Number
    {
    	return this.#touchdown_speed;
    }

	 get turn_angle() //: Angle
    {
    	return this.#turn_angle;
    }

	//other properties
	 get type_name() //: String
    {
		return this.#type_name;
	}

//constructor
	constructor (name)
	{
		this.#type_name = name;
		switch(name)
		{
			case AircraftType.#TYPE_COPTER:
				this.#acceleration = AircraftType.#ACCELERATION_COPTER;
				this.#cruise_speed = AircraftType.#CRUISE_SPEED_COPTER;
				this.#deceleration = AircraftType.#DECELERATION_COPTER;
				this.#landing_roll_length = AircraftType.#LAND_ROLL_LENGTH_COPTER;
				this.#liftoff_speed = AircraftType.#LIFTOFF_SPEED_COPTER;
				this.#takeoff_roll_length = AircraftType.#TO_ROLL_LENGTH_COPTER;
				this.#taxiing_speed = AircraftType.#TAXIING_SPEED_COPTER;
				this.#touchdown_speed = AircraftType.#TOUCHDOWN_SPEED_COPTER;
				this.#turn_angle = AircraftType.#TURN_ANGLE_COPTER;				
				break;
		case AircraftType.#TYPE_PROPELLER:
				this.#acceleration = AircraftType.#ACCELERATION_PROP;
				this.#cruise_speed = AircraftType.#CRUISE_SPEED_PROP;
				this.#deceleration = AircraftType.#DECELERATION_PROP;
				this.#landing_roll_length = AircraftType.#LAND_ROLL_LENGTH_PROP;
				this.#liftoff_speed = AircraftType.#LIFTOFF_SPEED_PROP;
				this.#takeoff_roll_length = AircraftType.#TO_ROLL_LENGTH_PROP;
				this.#taxiing_speed = AircraftType.#TAXIING_SPEED_PROP;
				this.#touchdown_speed = AircraftType.#TOUCHDOWN_SPEED_PROP;
				this.#turn_angle = AircraftType.#TURN_ANGLE_PROP;				
				break;
			case AircraftType.#TYPE_LINER:
				this.#acceleration = AircraftType.#ACCELERATION_LINER;
				this.#cruise_speed = AircraftType.#CRUISE_SPEED_LINER;
				this.#deceleration = AircraftType.#DECELERATION_LINER;				
				this.#landing_roll_length = AircraftType.#LAND_ROLL_LENGTH_LINER;
				this.#liftoff_speed = AircraftType.#LIFTOFF_SPEED_LINER;
				this.#takeoff_roll_length = AircraftType.#TO_ROLL_LENGTH_LINER;
				this.#taxiing_speed = AircraftType.#TAXIING_SPEED_LINER;
				this.#touchdown_speed = AircraftType.#TOUCHDOWN_SPEED_LINER;
				this.#turn_angle = AircraftType.#TURN_ANGLE_LINER;
				break;			
			case AircraftType.#TYPE_SUPERSONIC:
				this.#acceleration = AircraftType.#ACCELERATION_SUPER;
				this.#cruise_speed = AircraftType.#CRUISE_SPEED_SUPER;
				this.#deceleration = AircraftType.#DECELERATION_SUPER;				
				this.#landing_roll_length = AircraftType.#LAND_ROLL_LENGTH_SUPER;
				this.#liftoff_speed = AircraftType.#LIFTOFF_SPEED_SUPER;
				this.#takeoff_roll_length = AircraftType.#TO_ROLL_LENGTH_SUPER;				
				this.#taxiing_speed = AircraftType.#TAXIING_SPEED_SUPER;
				this.#touchdown_speed = AircraftType.#TOUCHDOWN_SPEED_SUPER;			
				this.#turn_angle = AircraftType.#TURN_ANGLE_SUPER;				
				break;
		}
	}

//public methods
    to_string() //: String
    {
		return "{\n[AircraftType]\n  TypeName=" + this.#type_name + "\n}";
    }	
}


///////////////////////////////////////////////////////////
//  AircraftState.as
///////////////////////////////////////////////////////////

class AircraftState extends Enum 
{
	static ARRIVING = new AircraftState("Arriving", 0);							//подлетающие к аэродрому самолеты, но еще не вошедшие в его зону
	static UNDIRECTED = new AircraftState("Undirected", 1);						//самолеты, маршрут для которых не задан
	static DIRECTED = new AircraftState("Directed", 2);							//самолеты, летящие по маршруту
	static APPROACHING = new AircraftState("Approaching", 3); 					//самолеты, производящие заход
    static LANDING = new AircraftState("Landing", 4);							//производящие посадку
    static TAXIING_TO_GATE = new AircraftState("TaxiingToGate", 5);				//рулящие к гейту
	static PREPARING_TO_TAKEOFF = new AircraftState("PreparingToTakeoff", 6);	//готовищиеся к взлету
    static READY_TO_TAKEOFF = new AircraftState("ReadyToTakeoff", 7);			//готовые к взлету
    static TAXIING_TO_AIRFIELD = new AircraftState("TaxiingToAirfield", 8);		//рулящие к ВВП
	static TAKING_OFF = new AircraftState("TakingOff", 9);						//взлетающие и взлетевшие, покидающие аэродром
	
	static values() {
	  return [AircraftState.ARRIVING,  AircraftState.UNDIRECTED,  AircraftState.DIRECTED,  AircraftState.APPROACHING,  
	  	AircraftState.LANDING,  AircraftState.TAXIING_TO_GATE, AircraftState.PREPARING_TO_TAKEOFF,  
	  	AircraftState.READY_TO_TAKEOFF,  AircraftState.TAXIING_TO_AIRFIELD,  AircraftState.TAKING_OFF];
	} //enum

	get is_coming()
	{
		return this == AircraftState.ARRIVING || this == AircraftState.DIRECTED || this == AircraftState.UNDIRECTED
			|| this == AircraftState.APPROACHING || this == AircraftState.LANDING;
	}	

	//public methods			
    to_string(indent=0) 
    {
		let str_indent = Instruments.string_of_char("\t", indent);
		let str_indent_plus = Instruments.string_of_char("\t", indent + 1);
		return str_indent + "[AircraftState]\n"
			+ str_indent + "{\n"
			+ str_indent_plus + "name=" + this.name + "\n"
			+ str_indent + "}\n";
    }	
}


///////////////////////////////////////////////////////////
//  Aircraft.as
///////////////////////////////////////////////////////////

class Aircraft extends SelectableObject
{
//public consts
	static get ARRIVAL_PERIOD() {return 8;} //sec
	static get ARRIVAL_PERIOD() {return 600;} //m	
	
	//go around reasons
	static get GA_REASON_NONE() {return 0;}
	static get GA_REASON_CLOUDS() {return 2;}
	static get GA_REASON_UNKNOWN() {return 3;}
	static get GA_REASON_WIND() {return 1;}
	

//protected consts
	_ANG_COURSE = Math.PI / 12; //ширина курса, deg
	_BRAKING = -8; //m/s

//protected fields
	_acceleration = 0;
	_airport_rect = null;
	_altitude = 0;
	_collided = false;
	_fuel = this.#MAX_FUEL;
	_is_occuping_airfield = false; 		
    _is_takeoff_pending = false; 
	_occupied_gate = null;		
    _path = null;
	_state = null;
    _target_airfield = null;
	_time_to_arrive = 0;
    _turn = 0;
	_type = null;
	_speed = 0;	
	_velocity = 0;	
	_waypoint_miss_ticks = 0;
	_xy_waypoint_distance = Number.MAX_VALUE;

//private consts
	#TURN_ADMIS_ERROR = new Angle(10, Angle.DEGREE); //deg
	#AIRCRAFT_SIZE = 750; //m
	#BOUNCE_BOUND = 1000; //m
	#COLLISION_HOR_DISTANCE = 300;
	#COLLISION_VERT_DISTANCE = 50;
	#CRITICAL_DOWNWIND = 20; //if more -> wind is considered is GA cause
	#FLARE_ALTITUDE = 30; //m	
	#FUEL_CONSUMPTION = 1; //secs of flight per second
	#FUELING_RATE = 5; //secs of flight per second
	#LANDING_DESCENT = -25; //m/s
	#LANDING_DETERIORATION_IN_CLOUD = 0.2;
	#MAX_FUEL = 768; //secs of flight
	#TAKEOFF_CLIMB = 50; //m/s
	#WAYPOINT_REACH_DISTANCE = 500; //m
	#COURSE_CHECK_POINTS = 3; //количество точек, по которым контролируется попадание маршрута в подход
	#CRITICAL_CLOUD_DENSITY = 80; //if more -> clouds are considered is GA cause
	#GA_FRAMES = 100; //frames after ga, when ga reason is set
	#MAX_WAYPOINT_MISS_TICKS = 32; //макс. кол-во тиков, при которых самолет летит мимо точки
	#WAYPOINT_REACH_DEPTH = 5;

//property fields
	#go_around_reason = Aircraft.GA_REASON_NONE;

//other fields
	#max_downwind_speed = 0; 
	#is_first_contact = true;
	#is_first_loss_of_contact = true;
	#cloud_density_counter = 0; 
	#go_around_frame_counter = 0;

//properties
	get altitude() //: Number
    {
    	return this._altitude;
    }

	get collided() //: Boolean
    {
    	return this._collided;
    }
	
	get fuel() //: Number
    {
    	return this._fuel / this.#MAX_FUEL;
    }

	get go_around_reason() //: int
    {
    	return this.#go_around_reason;
    }
	
	get is_occuping_airfield() //: Boolean
    {
    	return this._is_occuping_airfield;
    }

	get is_takeoff_pending() //: Boolean
    {
    	return this._is_takeoff_pending;
    }

	get occupied_gate() //: Gate
    {
    	return this._occupied_gate;
    }
			
    get path() //: Points
    {
    	return this._path;
    }
	
    get state() //: AircraftState
    {
    	return this._state;
    }

	get target_airfield() //: IAirfield
	{
		return this._target_airfield;
	}

	set target_airfield(airfield)
	{
		this.#reset_waypoint_miss_counter();
		
		if (!this._state.is_coming)
		{
			this.depart();
		}

		if (this._target_airfield && (this._target_airfield != airfield))
		{
			this.#free_airfield();
		}
		this._target_airfield = airfield;			
		
		if (this._state == AircraftState.DIRECTED && !this._target_airfield && this._path.length == 0)
			this._state = AircraftState.UNDIRECTED;
		else
			if (this._state == AircraftState.UNDIRECTED)
				this._state == AircraftState.DIRECTED;
	}

	get time_to_arrive() //: Number
	{
		return this._time_to_arrive;
	}

    get type() //: AircraftType
    {
    	return this._type;
    }
	
//constructor
	constructor(aircraft_type, location, course, airport_rect, state, fuel_residue, gate=null)
    {
		this._type = aircraft_type;
		this._path = new Points();
		this._path.on_add.add_event_listener(PointsEventDispatcher.ON_ADD, this.#points_on_add);
		this._path.on_remove.add_event_listener(PointsEventDispatcher.ON_REMOVE, this.#points_on_remove);

		super(location, new Size(this.#AIRCRAFT_SIZE, this.#AIRCRAFT_SIZE), course);

		this._state = state;
		this._fuel = fuel_residue * this.#MAX_FUEL;
		this._airport_rect = airport_rect;
		this._altitude = (this._state == AircraftState.PREPARING_TO_TAKEOFF) ? 0 : Aircraft.ARRIVAL_PERIOD;
		this._time_to_arrive = (this._state == AircraftState.ARRIVING) ? Aircraft.ARRIVAL_PERIOD : 0;
		this._speed = (this._state == AircraftState.UNDIRECTED) ? this._type.cruise_speed : 0;
		
		if (gate != null)
			gate.occupy();
		this._occupied_gate = gate;

    	this.on_landed = new CustomDispatcher();
    }

//public methods

	check_collision(other_aircraft, primary_check=true) //: Boolean
	{
		if (Math.abs(this.location.x - other_aircraft.location.x) <= this.#COLLISION_HOR_DISTANCE
			&& Math.abs(this.location.y - other_aircraft.location.y) <= this.#COLLISION_HOR_DISTANCE
			&& Math.abs(this.altitude - other_aircraft.altitude) <= this.#COLLISION_VERT_DISTANCE
			&& Instruments.xor(this.altitude == 0, other_aircraft.altitude != 0)
			)
		{
			this._collided= true;
			if (primary_check)
			{
				other_aircraft.check_collision(this, false);
			}
		}
		
		return this._collided;
	}

	depart() //: void
	{
		if (this._state == AircraftState.READY_TO_TAKEOFF)
			this._is_takeoff_pending = true;
		//дальнейшие действия по старту см. _stay_ready_to_takeoff()
	}

	in_area(point)
    {
		let pnt = point.sub(this.location);
		return pnt.Radius < this.#AIRCRAFT_SIZE / 2;
	}

	move(wind, cloud_density)
	{
		if (this.#go_around_frame_counter > 0) 
			--this.#go_around_frame_counter;
		else
			this.#go_around_reason = Aircraft.GA_REASON_NONE;
			
		this._control(wind, cloud_density);
		this._calc_speeds();
		this.#calc_location(wind);
	}

	to_string(indent=0) //: String
	{
		let str_indent = Instruments.string_of_char("\t", indent);
		let str_indent_plus = Instruments.string_of_char("\t", indent + 1);
		return str_indent + "[Aircraft]\n" 
			+ super.to_string(indent + 1) + "\n"
			+ str_indent_plus + "altitude=" + this._altitude + "\n"
			+ str_indent_plus + "collided=" + this._collided + "\n"
			+ str_indent_plus + "is_occuping_airfield=" + this._is_occuping_airfield + "\n"
			+ str_indent_plus + "is_takeoff_pending=" + this._is_takeoff_pending + "\n"
			+ str_indent_plus + "occupied_gate=\n" 
			+ (this._occupied_gate ? this._occupied_gate.to_string(indent + 2) : "")
			+ str_indent_plus + "state=" + this._state.to_string(indent + 2) + "\n"
			+ str_indent_plus + "target_airfield=\n" 
			+ (this._target_airfield ? this._target_airfield.to_string(indent + 2): "")
		+ str_indent + "}\n";	
	}

	//protected methods

	_approach(wind, cloud_density)
	{
		//ускорение и набор затем могут быть переопределены в this._land(), который использует данный метод
		this._acceleration = (this._speed > this._type.touchdown_speed) ? this._type.deceleration: 0;
		this._velocity = (this._altitude > this.#FLARE_ALTITUDE) ? 
			(this.#LANDING_DESCENT * (1 - this.#LANDING_DETERIORATION_IN_CLOUD * cloud_density)) 
			: 0;
			
		this.#max_downwind_speed = Math.max(wind.direction.sub(this.course).cos() * wind.speed, this.#max_downwind_speed);
		this.#cloud_density_counter += cloud_density;
		
		var is_in_landing_zone = this._target_airfield.in_landing_zone(this.location);
		
		var to_continue_approach = this._navigate_to_airfield(is_in_landing_zone, wind);
				
		if (to_continue_approach)
		{
			this.#capture_airfield();
		}
		
		return to_continue_approach && is_in_landing_zone;
	}

	_brake(wind)
	{
		//сели, теперь нужно затормозить
		this._acceleration = (this._speed > this._type.taxiing_speed) ? this._BRAKING: 0;
		this._velocity = (this._altitude > 0) ? this.#LANDING_DESCENT : 0;
	}

	_control(wind, cloud_density) //: Boolean
	{
		switch (this._state)
		{
			case AircraftState.ARRIVING:
				this.#arrive();
				break;

			case AircraftState.UNDIRECTED:
				this.#fly_undirected();
				break;
				
			case AircraftState.DIRECTED:
				this.#fly_directed(wind);
				break;

			case AircraftState.APPROACHING:
				this._approach(wind, cloud_density);
				break;
				
			case AircraftState.LANDING:
				this._land(wind, cloud_density);	
				break;
							
			case AircraftState.PREPARING_TO_TAKEOFF:
				this.#prepare_to_takeoff()
				break;
				
			case AircraftState.READY_TO_TAKEOFF:
				this._stay_ready_to_takeoff();
				break;
				
			case AircraftState.TAKING_OFF:
				this._takeoff(wind);
				break;
				
			default: 
				this._turn = 0;
				return false;
		}
		
		return true;
	}

	_convert_to_ground_speed(speed, wind)
	{
		return this._speed + this.course.sub(wind.direction).cos() * wind.speed;	
	}

	_convert_to_instrumental_speed(speed, wind)
	{
		return this._speed - this.course.sub(wind.direction).cos() * wind.speed;		
	}

	_declare_landed()
	{
		this._target_airfield.free(this);
		this._target_airfield = null;
		this._state = AircraftState.PREPARING_TO_TAKEOFF;
		//TODO: event
		//this.on_landed.fire_on_landed(this);				
	}

	_examine_go_around_reason()
    {
		if (this._state != AircraftState.LANDING) return;
		
		if (this.#max_downwind_speed > this.#CRITICAL_DOWNWIND)
			this.#go_around_reason = Aircraft.GA_REASON_WIND;
		else if (this.#cloud_density_counter > this.#CRITICAL_CLOUD_DENSITY)
			this.#go_around_reason = Aircraft.GA_REASON_CLOUDS;
		else
			this.#go_around_reason = Aircraft.GA_REASON_UNKNOWN;
		console.log("==============================");
		console.log("this._fuel = " + this._fuel);
		console.log("this.#go_around_reason = " + this.#go_around_reason);
		console.log("this._state = " + this._state.StateName);
		console.log("this.#max_downwind_speed = " + this.#max_downwind_speed);
		console.log("this.#cloud_density_counter = " + this.#cloud_density_counter);
		this.#go_around_frame_counter = this.#GA_FRAMES;
    }	

	_get_target_course() //: Angle
	{
		return this._target_airfield.course;
	}

	_go_around(wind)
	{
		this._loss_of_contact(wind);
		this.#free_airfield();
		this._examine_go_around_reason();
		this._state = AircraftState.UNDIRECTED;
	}

	_land(wind, cloud_density) //: Boolean
	{
		//заход
		let is_over_airfield = this._approach(wind, cloud_density);
		
		//если мы уже над полосой
		if (is_over_airfield && this._occupied_gate != null)
		{
			this._turn = this.course.get_rotation(this._target_airfield.active_course);
			
			if (this._altitude <= 0)
			{
				if (this.#is_first_contact) 
				{
					this._touchdown(wind);
				}
				return true;
			}
			else
			{
				//садимся							
				this._acceleration = (this._speed > this._type.touchdown_speed) ? this._type.deceleration: 0;
				this._velocity = (this._altitude > 0) ? this.#LANDING_DESCENT : 0;
			}
		}
		return false;
	}

	_loss_of_contact(wind)
	{
		this.#is_first_contact = true;
		this.#is_first_loss_of_contact = false;
	}
	
	_navigate_to_airfield(is_in_landing_zone, wind) //: Boolean
	{
		return true;
	}

	_stay_ready_to_takeoff() //: Boolean
	{
		this._turn = 0;
		this._acceleration = 0;
		if (this._is_takeoff_pending)
		{
			//если полоса для старта не опеределена берем свободную в текущий момент
			var airfield: IAirfield = this._target_airfield ? this._target_airfield : this._occupied_gate.HostingAirfield;
			this._is_occuping_airfield = airfield.occupyToTakeoff(this);
			if (this._is_occuping_airfield)
			{
				this._target_airfield = airfield;
				this._state = AircraftState.TAXIING_TO_AIRFIELD;
				this._occupied_gate.free(this);
				this._occupied_gate = null;
				return true;
			}
		}
		return false;
	}

	_stop()
	{
		this._speed = 0;
		this._acceleration = 0;
		this._turn = 0;
	}

	_takeoff(wind) 
	{
		if (this.#is_first_loss_of_contact)
		{
			this._loss_of_contact(wind) //hook
		}
		
		this._velocity = this.#TAKEOFF_CLIMB;
		if (this._target_airfield != null)
		{
			this._target_airfield.free(this);
			this._is_occuping_airfield = false;				
			this._target_airfield.Selected = false;
			this._target_airfield = null;
			this.selected = false;
		}
	}	
	
	_touchdown(wind) 
	{
		this._altitude = 0;
		this._velocity = 0;
		this.#is_first_contact = false;
		this.#is_first_loss_of_contact = true;
	}
	
//private methods
	#arrive()
	{
		this._time_to_arrive -= 1 / Core.FRAME_RATE;
		if (this._time_to_arrive <= 0)
		{
			this._state = AircraftState.UNDIRECTED;
			this._speed = this._type.cruise_speed;
		}
	}

	#calc_location(wind)
	{
		//calc altitude
		this._altitude += this._velocity / Core.FRAME_RATE;
		if (this._altitude < 0)
		{
			this._altitude = 0; 
			if (this._state.is_coming && (!this._target_airfield || !this._target_airfield.in_area(this.location)))
			{
					this._collided = true;
			}
		}

		//calc course
		this.course.radian += this._type.turn_angle.radian * this._turn / Core.FRAME_RATE * ((this.altitude == 0) ? 3 : 1);
		
		//calc position
		let x = this.course.sin() * this._speed / Core.FRAME_RATE;
		let y = -this.course.cos() * this._speed / Core.FRAME_RATE;
		
		if (this._altitude > 0)
		{
			x += wind.direction.sin() * wind.speed / Core.FRAME_RATE;
			y += -wind.direction.cos() * wind.speed / Core.FRAME_RATE;
		}
		
		location.x += x;
		location.y += y;		
	}

	_calc_speeds()
	{
		this._speed += this._acceleration / Core.FRAME_RATE;

		if (this._state.is_coming && this._velocity >= 0 && this._acceleration >= 0) 
		{
			this._fuel -= this.#FUEL_CONSUMPTION / Core.FRAME_RATE;
			if (this._fuel < 0)
			{
				this._fuel = 0;
			}
		}
		if (this._speed < 0) this._speed = 0;
		if (this._fuel == 0) this._velocity = this.#LANDING_DESCENT;
	}

	#capture_airfield()
	{
		if (this._target_airfield != null && !this._is_occuping_airfield)
		{
			this._occupied_gate = this._target_airfield.occupy_to_land(this);
			if (this._occupied_gate != null)
			{
				this._is_occuping_airfield = true;
				this._path.remove_all();
				this._state = AircraftState.LANDING;
			}
			else
				this._is_occuping_airfield = false;	
		}
	}

	#check_next_waypoint_accessibility()
	{
		let pnt_dist = this.location.sub(this._path.get(0));
		let xy_dist = Math.abs(pnt_dist.x) + Math.abs(pnt_dist.y);
		if (xy_dist <= this._xy_waypoint_distance) 
		{
			this._xy_waypoint_distance = xy_dist;
			this._waypoint_miss_ticks = 0;
			return false;
		}
		else
			return ++this._waypoint_miss_ticks > this.#MAX_WAYPOINT_MISS_TICKS;
	}

	#fly_directed(wind)
	{
		this._acceleration = (this._speed < this._type.cruise_speed) ? this._type.acceleration: 0;
		this._velocity = (this._altitude < Aircraft.ARRIVAL_PERIOD) ? this.#TAKEOFF_CLIMB : 0;	
		if (this._path.length > 0) //Выясняем, достижима ли текущая маршрутная точка
		{
			if (this.#check_next_waypoint_accessibility())
			{
				this._path.shift();
				this.#reset_waypoint_miss_counter();
			}
			
			this.#manage_reached_waypoints();
		}
		if (this.#is_ready_to_approach()) //Проверяем возможность захода
		{
			this._state = AircraftState.APPROACHING;
			this.#max_downwind_speed = 0; 
			this.#cloud_density_counter = 0; 
			this._path.remove_all();
			return;
		}
		else 
			if (this._target_airfield && this._path.length == 0)
				this._go_around(wind);
				
		if (this._path.length == 0) //Если точек нет и нет ВПП, то переходим в ненаправленный режим
		{
			if (!this._target_airfield)
			{
				this._state = AircraftState.UNDIRECTED;
				return;
			}
		}
		else
		{
			var ang_target = Angle.direction(this.location, Point(this._path.get(0)), {});			
			var ang_diff = ang_target.sub(this.course);
			//turn to waypoint
			this._turn = (Math.abs(ang_diff.radian) < this.#TURN_ADMIS_ERROR.radian) ? 0 : Instruments.sign(ang_diff.radian);
		}
	}

	#fly_undirected()
	{
		if (this.location.x - this._airport_rect.location.x < this.#BOUNCE_BOUND)
		{
			if (this.course.radian >= -Math.PI/2 && this.course.radian < Math.PI/2)
				this._turn = 1;
			else if (this.course.radian < -Math.PI/2 || this.course.radian > Math.PI/2)
					this._turn = -1;
		}
		else if (this._airport_rect.location.x + this._airport_rect.extent.width - this.location.x < this.#BOUNCE_BOUND)
		{
			if (this.course.radian < Math.PI/2 && this.course.radian > -Math.PI/2)
				this._turn = -1;
			else if (this.course.radian > Math.PI/2 || this.course.radian < -Math.PI/2)
				this._turn = 1;
		}						
		else if (this.location.y - this._airport_rect.location.y < this.#BOUNCE_BOUND)
		{
			if (this.course.radian < 0)
				this._turn = -1;
			else if (this.course.radian > 0)
				this._turn = 1;
		}				
		else if (this._airport_rect.location.y + this._airport_rect.extent.height - this.location.y < this.#BOUNCE_BOUND)
		{
			if (this.course.radian < 0)
				this._turn = 1;
			else if (this.course.radian > 0)
				this._turn = -1;
		}						
		else 
			this._turn = 0;
			
		this._acceleration = (this._speed < this._type.cruise_speed) ? this._type.acceleration : 0;
		this._velocity = (this._altitude < Aircraft.ARRIVAL_PERIOD) ? this.#TAKEOFF_CLIMB : 0;
	}

	#free_airfield()
	{
		if (this._is_occuping_airfield) 
		{
			this._target_airfield.free(this);
			if (this._occupied_gate != null)
			{
				this._occupied_gate.free(this);
				this._occupied_gate = null;
			}
			this._is_occuping_airfield = false;
		}
		if (this._target_airfield != null)
		{
			this._target_airfield.Selected = false;
			this._target_airfield = null;
		}
	}
			
	#is_on_course(waypoint, target_course) //:Boolean
	{
		let o_dist = {Distance: 0.0};
		let ang_targe = Angle.direction(waypoint, this._target_airfield.location, o_dist);
		let ang_diff = ang_target.sub(target_course);

		return ang_diff.abs().radian < this._ANG_COURSE/2 || ang_diff.abs().sub(Angle.PI).abs().radian < this._ANG_COURSE/2;
	}

	#is_ready_to_approach()
	{
		//Если не задана ВПП - заход делать некуда
		if (!this._target_airfield || this._path.length == 0) return false;
		
		//проверяем, не можем ли мы сделать заход
		let n_step = Math.floor(this._path.length / this.#COURSE_CHECK_POINTS);
		let is_on_course = true;
		var ang_course = this._get_target_course();
  		for (let i = 0; is_on_course && i < this.#COURSE_CHECK_POINTS; i++)
		{
			is_on_course &&= this.#is_on_course(Point(this._path.get(i * n_step)), ang_course);
		}
		
		return is_on_course; 
	}

	#manage_reached_waypoints()
	{
		for (let i = Math.min(this._path.length - 1, this.#WAYPOINT_REACH_DEPTH); i >= 0; i--)
		{
			if (this.#waypoint_reached(this._path.get(i)))
			{
				this._path.remove_at(0, i + 1);
				this.#reset_waypoint_miss_counter();
				break;
			}
		}
	}

	#prepare_to_takeoff()
	{
		if (this._fuel < this.#MAX_FUEL)
			this._fuel += this.#FUELING_RATE / Core.FRAME_RATE;
		else
		{
			this._fuel = this.#MAX_FUEL;
			this._is_takeoff_pending = false;
			this._state = AircraftState.READY_TO_TAKEOFF;
		}
	}

	#reset_waypoint_miss_counter()
	{
		this._waypoint_miss_ticks = 0;
		this._xy_waypoint_distance = Number.MAX_VALUE;					
	}
		
	#waypoint_reached(waypoint)
	{
		return (Math.abs(waypoint.x - this.location.x) < this.#WAYPOINT_REACH_DISTANCE 
			&& Math.abs(waypoint.y - this.location.y) < this.#WAYPOINT_REACH_DISTANCE);

	}

	//event handlers
	#points_on_add(event)
	{
		//console.log("    On add waypoint:");
		if (this._target_airfield || this._path.length > 0)
		{
			this.#reset_waypoint_miss_counter();
			this._state = AircraftState.DIRECTED;
			//console.log("        Aircraft state => Directed");
		}
	}

	#points_on_remove(event)
	{
		//console.log("    On remove waypoint:");
		if (this._state == AircraftState.DIRECTED && !this._target_airfield && this._path.length == 0)
		{
			this._state = AircraftState.UNDIRECTED;
			//console.log("        Aircraft state => Undirected");			
		}
	}
}


///////////////////////////////////////////////////////////
//  Plane.as
/////////////////////////////////////////////////////////// 
class Plane extends Aircraft
{
//public consts
	static get DBL_NORMAL_ALTITUDE() {return 600;} //m	

//private fields & consts

	//private consts
	#PERMISSIBLE_APPROACH_ERROR = Math.PI / 9; //rad
	#PERMISSIBLE_CENTERLINE_ERROR = 200; //m
	#PERMISSIBLE_GATE_STOP_ERROR = 150; //m
	#PERMISSIBLE_TURN_ERROR = Math.PI / 18; //rad	
	#COURSE_ERROR_DISTANCE = 500; //m	

	//-подрежимы руления
	#TAXI_SUBMODE_ENTRY: int = 0; 	//выезд на ВПП,
	#TAXI_SUBMODE_DOWNWIND: int = 1; //движение по ВВП в сторону, обратную курсу
	#TAXI_SUBMODE_U_TURN: int = 2;	//разворот на курс
	#TAXI_SUBMODE_CENTERLINING: int = 3;	//выравнивание на центральную линию	

	//other fields
	#is_gate_changed = false;
	#taxi_submode = -1;

//constructor
    constructor(aircraft_type, location, course, airport_rect, state, fuel_residue, gate=null)
    {
		super(aircraft_type, location, course, airport_rect, state, fuel_residue, gate);
    }

//protected methods
	_approach(wind, cloud_count)
	{
		//проверяем хватит ли остатка ВПП для посадки
		if (!this.#check_runway_remainder(wind))
		{
			return false;
		}

		return super._approach(wind, cloud_count);
	}

	_brake(wind)
	{
		super.this._brake(wind);
		
		//затормозили - рулим
		if (this._speed <= this._type.taxiing_speed) 
		{
			
			this.#is_gate_changed = false;
			this._state = AircraftState.TAXIING_TO_GATE;
			this._target_airfield.selected = false;
		}
		else 
		{
			this.#check_runway_remainder(wind);
		}
	}	

	_control(wind, cloud_count) //: Boolean
	{
		if (super._control(wind, cloud_count)) return true;
	
		switch (this._state)
		{			
			case AircraftState.TAXIING_TO_GATE:
				this.#taxi_to_gate();
				break;			
				
			case AircraftState.TAXIING_TO_AIRFIELD:
				this.#taxi_to_takeoff();
				break;

			case AircraftState.TAKING_OFF:
				this._takeoff(wind);
				break;

			default: 
				this._turn = 0;
				return false;
		}
		
		return true;
	}
	
	_land(wind, cloud_density) //: Boolean
	{
		var is_landed = super._land(wind, cloud_density);
		if (is_landed)
		{
			this._brake(wind);
		}

		return is_landed;
	}

	_loss_of_contact(wind)
	{
		if (this._altitude <= 0) 
		{
			this._speed = super._convert_to_instrumental_speed(this._speed, wind);
		}
		super._loss_of_contact(wind);
	}	
	
	_navigate_to_airfield(is_in_landing_zone, wind) //: Boolean
	{
		//заход: основной принцип следовать курсом равным азимуту на центр ВПП плюс еще внутрь на удвоенную разницу между курсом ВПП и 
		//азимутом на центр ВПП. Например: курс ВПП = 90грд. Азимут на центр = 80грд. Разница = 10грд. Следвать 80 - 10*2 = 60грд.
		//азимут на центр ВПП
		var obj_dist = {Distance: 0.0};
		var ang_to_runway = Angle.direction(this.location, this._target_airfield.location, obj_dist);		
		
		//здесь не работает ILS
		if (obj_dist.Distance < this.#COURSE_ERROR_DISTANCE)
		{
			this._turn = this.course.get_rotation(this.#get_landing_course());
			return true;
		}
		else
		{			
			return this.#align_localizer(ang_to_runway, is_in_landing_zone, wind);
		}	
	}


	_stay_ready_to_takeoff() //: Boolean
	{
		var is_takeoff_allowed = super._stay_ready_to_takeoff();
		if(is_takeoff_allowed)
		{
			this.#taxi_submode = this.#TAXI_SUBMODE_ENTRY;
		}

		return is_takeoff_allowed;
	}
	
	_takeoff(wind)
	{
		//ехать с курсом ВПП
		this._turn = (this._target_airfield == null) ? 0 : this.course.get_rotation(this._target_airfield.active_course);
		//набирая скорость до нормальной
		this._acceleration = (this._speed < this._type.cruise_speed) ? this._type.acceleration : 0;
		//при скорости отрыва набирать высоту
		let dbl_instr_speed = (this._altitude > 0) ? this._speed : this._convert_to_instrumental_speed(this._speed, wind);			
		if (dbl_instr_speed > this._type.liftoff_speed)
		{
			super._takeoff(wind);
		}
	}	
	
	_touchdown(wind) 
	{
		this._speed = this._convert_to_ground_speed(this._speed, wind);
		super._touchdown(wind);		
	}	
	
//private methods

	#align_localizer(angle_to_runway, is_in_landing_zone, wind)
	{
		//получаем посадочный курс
		let ang_rw_course = this.#get_landing_course();
		
		//угол между азимутом на ВПП и курсом ВПП
		var ang_diff2 = angle_to_runway.sub(ang_rw_course);

		//Действие ILS
		angle_to_runway.inc(ang_diff2);
		angle_to_runway.inc(ang_diff2);
		
		//Уход на круг
		var dbl_abs_err = Math.abs(ang_diff2.radian);

		if ((dbl_abs_err > this.#PERMISSIBLE_APPROACH_ERROR) 
			&& !is_in_landing_zone && this._altitude > 0)
		{
			this._go_around(wind);
			return false;	
		}	
		else
		{
			this._turn = this.course.get_rotation(angle_to_runway);
			return true;
		}
	}
	
	#check_runway_remainder(wind)
	{
			//trace('this.#check_runway_remainder()');
			//азимут на центр ВПП
			var obj_dist = {Distance: 0.0};
			var ang_to_runway = Angle.direction(this.location, this._target_airfield.location, obj_dist);
			//trace(' ang_to_runway='+ang_to_runway.Degree);
			//trace(' obj_dist.Distance='+obj_dist.Distance);			
			//получаем посадочный курс
			var ang_rw_course = this.#get_landing_course();
			//trace(' ang_rw_course='+ang_rw_course.Degree);
			//угол между азимутом на ВПП и курсом ВПП
			var ang_diff = ang_to_runway.sub(ang_rw_course);
			//trace(' ang_diff=' + ang_diff.Degree);
			//считаем остаток ВПП
			var dbl_rw_remainder = this._target_airfield.length / 2 + obj_dist.Distance * ((ang_diff.abs().radian < Math.PI/2) ? +1 : -1);
			//trace(' dbl_rw_remainder='+dbl_rw_remainder);
			//получаем проекцию скорости ветра на курс
			var dbl_wind_proj = wind.speed * wind.direction.sub(ang_rw_course).cos();
			//если полосы не хватает уходим на круг
			if (dbl_rw_remainder < this._type.landing_roll_length * (this._speed + dbl_wind_proj - this._type.TaxiingSpeed) / (this._type.touchdown_speed - this._type.taxiing_speed))
			{
				this._go_around(wind);
				return false;
			}
			//trace('this.#check_runway_remainder=true')

			return true;
	}

	#get_course_and_distance(airfield, result) //method fills the given object with results
	{
		result.Course.radian = airfield.course.radian;
		var ang_from_aircraft = Angle.direction(this.location, airfield.location, result);
		var ang_diff = ang_from_aircraft.sub(airfield.course);
		if (ang_diff.abs().radian > Math.PI / 2)
                        result.Course.dec(Angle.PI);
		result.BackCourse = result.Course.sub(Angle.PI);
	}
	
	#get_course_to_centerline() //: Angle
	{
		//1. получаем азимут на ВПП
		//		берем азимут перпендикулярный курсу ВПП
		var ang_to_centerline = this._target_airfield.course.add(Angle.HALF_PI);
		//      получаем курс на центр
		var obj_dist = {Distance: 0.0};
		var ang_to_runway = Angle.direction(this.location, this._target_airfield.location, obj_dist);
		//		считаем разницу между ними
		var ang_diff = ang_to_runway.sub(ang_to_centerline);
		//		если разница больше Пи/2 то берем встречный перпендикуляр
		if (ang_diff.abs().radian > Math.PI/2)
		{
			ang_to_centerline.dec(Angle.PI);
		}
		return ang_to_centerline;
	}
	
	#get_landing_course() //: Angle
	{
		//trace('this.#get_landing_course()');
		if (this._state == AircraftState.LANDING)
		{
			//trace('this.#get_landing_course='+FTargetAirfield.ActiveCourse.Degree);
			return this._target_airfield.active_course;
		}
		else
		{
			var obj_rw_dir = {Course: new Angle(), BackCourse: new Angle(), Distance: 0.0};
			this.#get_course_and_distance(this._target_airfield, obj_rw_dir);
			//trace('this.#get_landing_course='+ obj_rw_dir.Course.Degree); 
			return obj_rw_dir.Course;
		}
	}
	
	#taxi_downwind()
	{
		var obj_rw_dir2 = {Course: new Angle(), BackCourse: new Angle(), Distance: 0.0};
		this.#get_course_and_distance(this._target_airfield, obj_rw_dir2);
		var dbl_run_dist = this._target_airfield.length / 2 
			+ obj_rw_dir2.Distance * ((obj_rw_dir2.Course.radian == this._target_airfield.active_course.radian) ? +1 : -1);
		if (dbl_run_dist < this._type.takeoff_roll_length)
		{
			this._turn = this.course.get_rotation(this._target_airfield.active_course.sub(Angle.PI));						
		}
		else
		{
			this.#taxi_submode = this.#TAXI_SUBMODE_U_TURN;
			this.#taxi_u_turn();
		}
	}
	
	#taxi_to_centerline()
	{
		if(this._target_airfield.get_distance_to_centerline(this.location) <= this.#PERMISSIBLE_CENTERLINE_ERROR)
		{
			this._state = AircraftState.TAKING_OFF;
			this._turn = 0;
		}
		else
		{
			this._turn = this.course.get_rotation(this.#get_course_to_centerline());
		}
	}

	#taxi_to_gate()
	{
		if (!this.#is_gate_changed)
		{
			this._occupied_gate = this._target_airfield.exchange_gate(this._occupied_gate, this.location);
			this.#is_gate_changed = true;
		}

		this._velocity = 0;
		this._acceleration = (this._speed > this._type.taxiing_speed) ? DBL_BRAKING : 0;
		
		var obj_rw_dir = {Course: new Angle(), BackCourse: new Angle(), Distance: 0.0};
		this.#get_course_and_distance(this._target_airfield, obj_rw_dir);
		//получаем азимут на гейт и расстояние до него		
		var obj_dist = {Distance: 0.0};
		var ang_to_gate = Angle.direction(this.location, this._occupied_gate.location, obj_dist);
		//смотрим угол между курсом к центру ВПП и азимутом на гейт
		var ang_diff = new Angle(Math.abs(obj_rw_dir.Course.sub(ang_to_gate).radian), Angle.RADIAN);
		//если модуль угла почти Пи/2, поворачиваем на гейт
		if (ang_diff.sub(Angle.HALF_PI).abs().radian < this.#PERMISSIBLE_TURN_ERROR)
		{
			this._turn = this.course.get_rotation(ang_to_gate);
			//контроллируем расстояние до гейта, чтобы затормозить и сменить статус						
			if (obj_dist.Distance < this.#PERMISSIBLE_GATE_STOP_ERROR)
			{
				this._stop();
				this._declare_landed();
			}
		}
		else 
			if(this._target_airfield.get_distance_to_centerline(this.location) > this.#PERMISSIBLE_CENTERLINE_ERROR)
				this._turn = this.course.get_rotation(this.#get_course_to_centerline());
			else
				//если угол меньше Пи/2 
				//то есть гейт находится по ходу к центру ВПП:
				//не доехали еще до гейта, но и не пробежали центр
				//или и проехали гейт и уже пробежали центр ВПП
				if (ang_diff.radian < Math.PI / 2) 
					this._turn = this.course.get_rotation(obj_rw_dir.Course); //продолжаем движение по курсу ВПП
				else 
				{	
					//гейт находится по ходу от центра ВПП: 
					//проехали гейт и не пробежали еще центр ВПП
					//или пробежали центр, но не доехали еще до гейта
					this._turn = this.course.get_rotation(obj_rw_dir.BackCourse); //держим курс на курс обратный курсу ВПП
				}
	}

	#taxi_to_runway()
	{
		if (this._target_airfield.get_distance_to_centerline(this.location) > this.#PERMISSIBLE_CENTERLINE_ERROR)
		{
			this._turn = this.course.get_rotation(this.#get_course_to_centerline());
		}
		else
		{
			this.#taxi_submode = this.#TAXI_SUBMODE_DOWNWIND; 
			this.#taxi_downwind();
		}
	}
	
	#taxi_to_takeoff()
	{
		this._acceleration = (this._speed < this._type.taxiing_speed) ? this._type.acceleration*2 : 0;

		switch(this.#taxi_submode)
		{
			case this.#TAXI_SUBMODE_ENTRY:
				this.#taxi_to_runway();
				break;
			case this.#TAXI_SUBMODE_DOWNWIND:
				this.#taxi_downwind();
				break;
			case this.#TAXI_SUBMODE_U_TURN:
				this.#taxi_u_turn();
				break;
			case this.#TAXI_SUBMODE_CENTERLINING:
				this.#taxi_to_centerline();
				break;
		}
	}
	
	#taxi_u_turn()
	{
		var ang_diff = this._target_airfield.active_course.sub(this.course);
		if(Math.abs(ang_diff.radian) > this.#PERMISSIBLE_TURN_ERROR)
		{
			this._turn = this.course.get_rotation(this._target_airfield.active_course);
		}
		else
		{
			this.#taxi_submode = this.#TAXI_SUBMODE_CENTERLINING;
			this.#taxi_to_centerline();
		}
	}
}


///////////////////////////////////////////////////////////
//  Copter.as
///////////////////////////////////////////////////////////
public class Copter extends Aircraft
{
	//constructor
    constructor(aircraft_type, location, course, airport_rect, state, fuel_residue, gate=null)
    {
		super(aircraft_type, location, course, airport_rect, state, fuel_residue, gate);
		if (gate) 
		{
			gate.occupy_to_land(this);
		}
    }

//protected methods
	_declare_landed()
	{
		this.#state = AircraftState.PREPARING_TO_TAKEOFF;
		this.on_landed.fire_on_landed(this);				
	}	
	
	_get_target_course() //: Angle
	{
		return Angle.direction(this.location, this.target_airfield.location, {});
	}

	_navigate_to_airfield (is_in_landing_zone, wind) //: Boolean
	{
		this._turn = this.course.get_rotation(Angle.direction(this.location, this._target_airfield.location, {}));
		return true;
	} 

	_stay_ready_to_takeoff() //: Boolean
	{
		let is_ready = super._stay_ready_to_takeoff();
		if (is_ready)
		{
			this._state = AircraftState.TAKING_OFF;
		}
		return is_ready;
	}

	_takeoff(wind)
	{
		this._acceleration = (this._speed < this._type.cruise_speed) ? this.type.acceleration : 0;
		super._takeoff(wind);
	}	

	_touchdown(wind)
	{
		super._touchdown(wind);
		stop();
		this._declare_landed();
	}
}


///////////////////////////////////////////////////////////
//  IAirfield.as
///////////////////////////////////////////////////////////

//interface IAirfield
//properties
//	get active_course() //: Angle;
//	get back_course_lights_distance() //: Number;
//	get course() //: Angle	
//	get course_lights_distance() //: Number;
//	get gates() //: Vector.<Gate>;
//	get is_runway() //: Boolean;	
//	get length() //: Number;
//  get location() //: Point;
//  set location(AValue: Point);
//	get occupied() //: Boolean;
//	get occupied_by() //: Aircraft;
//  get selected() //: Boolean
//  set selected(IsSelected)	
//	get upwind_course() //: Angle;
//	get width() //: Number;
//methods
//  exchange_gate(gate, location) //: Gate;
//  free(aircraft) //: void;
//  get_region() //: Region;
//  in_area(point);
//  in_landing_zone(point) //: Boolean;
//  occupy_to_land(aircraft) //: Gate;
//  occupy_to_takeoff(aircraft) //: Boolean;
//  to_string(indent=0) //: String;
//  to_xml(xml_node);
//  update_wind(wind_direction);


///////////////////////////////////////////////////////////
//  Runway.as
///////////////////////////////////////////////////////////

class Runway extends SelectableObject //implements IAirfield
{
//const
	get DBL_DEFAULT_LENGTH() {return 4000}
	get DBL_LANDING_ZONE_WIDTH_RATIO() {return 0.7}
	get DBL_WIDTH() {return 700}
	
//fields
	#active_course
	#back_course_lights_distance = 0;
	#course_lights_distance = 0;
	#gates = [];
	#occupied_by = null;
	#upwind_course = null;
	#ang_wind_direction = null;

	constructor(xml, airport)
	{
		let x = 0;
		let y = 0;
		let cy_length = this.DBL_DEFAULT_LENGTH;
		let ang_course = new Angle();
		
		if (xml)
		{
			x = xml.@x;
			y = xml.@y;
			cy_length = xml.@length;
			ang_course.degree = xml.@course;
			let dbl_course_lights_dist = xml.@courseLights;
			let dbl_backcourse_lights_dist = xml.@backcourseLights;
			if (dbl_course_lights_dist) this.#course_lights_distance = xml.@courseLights;
			if (dbl_backcourse_lights_dist) this.#back_course_lights_distance = xml.@backcourseLights;
					
			this.#load_gates_from_xml(xml.gates[0], airport);
		}
		
		super(new Point(x, y), new Size(this.DBL_WIDTH, cy_length), ang_course);
		
		this.#active_course = ang_course;
	}
	
//properties

	get active_course() //: Angle
	{
		return this.#active_course;
	}

	get back_course_lights_distance() //: Number
	{
		return this.#back_course_lights_distance;
	}

	get course_lights_distance() //: Number
	{
		return this.#course_lights_distance;
	}
	
	get has_free_gate() //: Boolean
	{
		for (let i = 0; i < this.#gates.length; i++)
		{
			if (this.#gates[i].free)
				return true;
		}		
		return false;
	}

	get gates() //: Vector.<Gate>
	{
		return this.#gates;
	}
	
	get is_runway() //: Boolean
	{
		return true;
	}	
	
	get length() //: Number
	{
		return this.#extent.height;
	}

	get occupied() //: Boolean
	{
		return (this.#occupied_by != null);
	}
	
	get occupied_by() //: Aircraft
	{
		return this.#occupied_by;
	}		

	get upwind_course() //: Angle
	{
		return this.#upwind_course;
	}
	
	get width() //: Number
	{
		return this.#extent.width;
	}

//methods
	exchange_gate(gate, location) //: Gate
	{
		let dbl_min_dist = Number.MAX_VALUE;
		let gt_nearest = null;
		for (let g of this.#gates)
		{
			if (!g.free && g != gate) continue;
			
			let pnt_rel = location.sub(g.location);
			let dbl_dist = Math.max(Math.abs(pnt_rel.x), Math.abs(pnt_rel.y));
			if (dbl_dist < dbl_min_dist)
			{
				dbl_min_dist = dbl_dist;
				gt_nearest = gate;
			}
		}
		
		if (gt_nearest && gt_nearest != gate) 
		{
			gate.free(null);
			gt_nearest.occupy();
			return gt_nearest;
		}
		else
			return gate;
	}

	free(aircraft) //: void
	{
		if (aircraft == this.#occupied_by)
			this.#occupied_by = null;
	}

	get_distance_to_centerline(point)
	{
		let pnt = point.sub(this.location);
		let ang_theta = pnt.theta;
		pnt.theta = ang_theta.sub(this.course);
		return Math.abs(pnt.x);
	}
		
	get_region() //: Region
	{
		return Region(this);
	}	
	
	in_landing_zone(point) //: Boolean
	{
		let mo_landing_zone = this.clone_object();
		mo_landing_zone.extent.width *= this.DBL_LANDING_ZONE_WIDTH_RATIO;
		return mo_landing_zone.in_area(point);
	}		
		
	occupy_to_land(aircraft) //: Gate
	{
		if (this.#occupied_by != null) return null;
		
		var gate = null;
		
		for (let gt of this.#gates)
		{
			if (gt.free) 
			{
				gate = gt;
				break;
			}
		}

		if (gate != null)
		{
			gate.occupy();
			this.#occupied_by = aircraft;
			this.#active_course = this.choose_runway_course(Angle.direction(aircraft.location, this.location, {}));
			//console.log('!!!FActiveCourse=' + FActiveCourse.Degree);
		}
		return gate;
	}

	occupy_to_takeoff(aircraft) //: Boolean
	{
		if (this.#occupied_by != null) return false;
		
		this.#occupied_by = aircraft;
		this.#active_course = this.#upwind_course;
		return true;
	}

	to_string(indent=0) //: String
	{
		let str_indent = Instruments.string_of_char("\t", indent);
		let str_indent_plus = Instruments.string_of_char("\t", indent + 1);		
		return str_indent + "[Runway]\n" 
			+ super.to_string(indent + 1) 
			+ str_indent_plus + "active_coure=" + this.#active_course + "\n"
			+ str_indent_plus + "occupied_by=" + this.#occupied_by + "\n"
			+ str_indent + "}\n";	
	}

	to_xml(xml_node)
	{
		super.to_xml(xml_node);
		
		xml_node.@length = this.extent.height;
			
		let xml_gates = new XML('<gates></gates>');
		xml_node.appendChild(xml_gates);
			
		for (let gate of this.gates)
		{
			let xml_gate = new XML('<gate></gate>');
			xml_gates.appendChild(xml_gate);
			xml_gate.@ref = gate.id;
		}
	}

	update_wind(wind_direction)
	{
		this.#upwind_course = this.#chooseRunwayCourse(wind_direction.sub(Angle.PI));	
	}

	//private methods
	#choose_runway_course(reference_course)
	{
		let ang_course = this.course.clone();
		if (reference_course.sub(ang_course).abs().radian > Math.PI / 2)
		{
			ang_course.dec(Angle.PI);								
		}
		return ang_course;
	}	
	
	#load_gates_from_xml(gates_node, airport)
	{
		for (let xml_gate of gates_node.gate)
		{
			let str_id = xml_gate.@ref;

			let gate = airport.find_gate(str_id);
			
			if (gate)
			{
				gate.associate(this);
				this.#gates.push(gate);
			}
		}
	}
}

///////////////////////////////////////////////////////////
//  Gate.as
///////////////////////////////////////////////////////////

class Gate extends SelectableObject
{
	get DBL_SELECT_RADIUS {return 400};
    #free = true;
    #id = "";
	#arw_hosting_airfields = [];

    constructor(id, location, is_free)
    {
		super(location, new Size(0, 0), new Angle());
		this.#id = id;
		this.#free = is_free;
    }

	static from_xml(xml) //: Gate
	{
		var obj_gate_props = get_gate_props_from_xml(xml);	
		return new Gate(obj_gate_props.id, obj_gate_props.location, obj_gate_props.is_free);
	}	
	
//properties

    get free() //: Boolean
    {
    	return this.#free;
    }

    get hosting_airfield() //: IAirfield
    {
		for (let airfield of arw_hosting_airfields)
		{
			if (!airfield.occupied) return airfield; 
		}
    	return arw_hosting_airfields[0];
    }

    get id() //: String
    {
    	return this.#id;
    }

//public methods
    associate(hosting_airfield) //: void
    {
		arw_hosting_airfields.push(hosting_airfield);
	}

    free(aircraft) //: void
    {
		this.#free = true;
    }
    
    in_area(point)
    {
		var point = point.sub(this.location);
		return point.radius < this.DBL_SELECT_RADIUS;
	}
	
	is_hosted_by(airfield) //: Boolean
    {
		for (let airfield of this.#arw_hosting_airfields)
			if (airfield == airfield) return true;

		return false;
    }

    occupy() //: Boolean
    {
		let is_free = this.#free;
		this.#free = false;
		return is_free;
	}

	to_string(indent = 0) //: String
	{
		let str_indent = Instruments.string_of_char("\t", indent);
		let str_indent_plus = Instruments.string_of_char("\t", indent + 1);
		
		return str_indent + "[Gate]\n" 
			+ str_indent + "{\n"
			+ super.to_string(indent + 1)
			+ str_indent_plus + "id=" + this.#id + "\n"
			+ str_indent_plus + "free=" + this.#free + "\n"
			+ str_indent + "}\n";	
	}

	to_xml(xml_node)
	{
		super.to_xml(xml_node);
		
		xml_node.@free = this.#free;
		xml_node.@id = this.#id;
	}	

//protected methods
	_get_gate_props_from_xml(xml) //: Object
	{		
		var obj_props = {id: "", location: new Point(0, 0), is_free: true};
		obj_props.id = AnXml.@id;					
		obj_props.location.x = AnXml.@x;
		obj_props.location.y = AnXml.@y;
		var str_free: String = AnXml.@free;
		obj_props.is_free = Instruments.str2Bool(str_free);
		return obj_props;
	}
}


///////////////////////////////////////////////////////////
//  Helipad.as
///////////////////////////////////////////////////////////

class Helipad extends Gate //implements IAirfield
{
	get #DBL_HELIPAD_LENGTH() {return 1000};
	get #DBL_HELIPAD_WIDTH() {return DBL_HELIPAD_LENGTH};
//property fields
	#active_course = new Angle(0, AngleUnits.RADIAN);
	#occupied_by = null;
    
    constructor(id, location, is_free)
    {
		super(id, location, is_free);
		this.extent = new Size(this.DBL_HELIPAD_WIDTH, this.DBL_HELIPAD_LENGTH);
		associate(this);
    }

	static from_xml(xml) //: Helipad
	{
		let obj_gate_props = Gate._get_gate_props_from_xml(xml);	
		return new Helipad(obj_gate_props.id, obj_gate_props.location, obj_gate_props.is_free);
	}
	
//properties
	get active_course() //: Angle
	{
		return this.#active_course;
	}

	get back_course_lights_distance() {return -1};
	get course_lights_distance() {return -1};
	
	get gates() //: Vector.<Gate>
	{
		return [this];
	}

	get is_runway() //: Boolean
	{
		return false;
	}
	
	get length() //: Number
	{
		return this.extent.height;
	}

	get occupied() //: Boolean
	{
		return (this.#occupied_by != null);
	}
	
	get occupied_by() //: Aircraft
	{
		return this.#occupied_by;
	}		

	get upwind_course() //: Angle
	{
		return null;
	}
	
	get width() //: Number
	{
		return this.extent.width;
	}

//methods
	exchange_gate(gate, location) //: Gate
	{
		return gate;
	}

	free(aircraft) //: void
	{
		this.#occupied_by = null;
		super.free(aircraft);
	}

	get_region() //: Region
	{
		return Region(this);
	}

	is_hosted_by(airfield) //: Boolean
    {
		return this == airfield;
    }

	in_landing_zone(point) //: Boolean
	{
		return in_area(point);
	}
	
	occupy_to_land(aircraft) //: Gate
	{
		if (this.#occupied_by != null) return null;
		
		this.occupy();
		this.#occupied_by = aircraft;
		this.#active_course = Angle.direction(aircraft.location, this.location, {});

		return this;
	}		
		
	occupy_to_takeoff(aircraft) //: Boolean
	{
		if (this.#occupied_by != null && this.#occupied_by != aircraft) return false;
		
		this.#occupied_by = aircraft;
		return true;		
	}

	to_string(indent=0) //: String
	{
		let str_indent = Instruments.string_of_char("\t", indent);
		let str_indent_plus = Instruments.string_of_char("\t", indent + 1);
		
		return str_indent + "[Helipad]\n" 
			+ str_indent + "{\n"
			+ super.to_string(indent + 1)
			+ str_indent_plus + "id=" + this.id + "\n"
			+ str_indent_plus + "free=" + this.free + "\n"
			+ str_indent + "}\n";	
	}

	to_xml(xml_node)
	{
		super.to_xml(xml_node);
	}	
	
	update_wind(wind_direction) {}
}


///////////////////////////////////////////////////////////
//  Airport.as
///////////////////////////////////////////////////////////

class Airport 
{
	#aircrafts;
	#airfields;
	#aprons;
	#cloud_probability;
	#clouds;
	#current_wind;
	#gates;
	#is_thumbnail_mode;
	#location;
	#extent;

	constructor(is_thumbnail_mode = false) {
		//TODO: events
		// this.on_gate_loaded  = new CustomDispatcher();
		// this.on_level_loaded = new CustomDispatcher();
		// this.on_resized = new CustomDispatcher();
		this.#aircrafts = [];
		this.#airfields = [];
		this.#aprons = [];
		this.#cloud_probability = 0;
		this.#clouds = [];
		this.#current_wind = null;
		this.#gates = [];
		this.#is_thumbnail_mode = is_thumbnail_mode;
		this.#location = new Point(0, 0);
		this.#extent = new Size(0, 0);

		console.log("Airport created!");
}

//getters
	get aircrafts() {return this.#aircrafts;}
	get airfields() {return this.#airfields;}
	get aprons() {return this.#aprons;}
	get clouds() {return this.#clouds;}	
	get cloud_probability() {return this.#cloud_probability;	}	
	get current_wind() {return this.#current_wind;}	
	get gates() {return this.#gates;}
	get is_thumbnail_mode() {return this.#thumbnail_mode;}

//methods

	//public methods
	find_gate(gate_id) //: Gate
	{
		for (let gate of this.#gates)
		{
			if (gate.id == gate_id)
				return gate;
		}
		return null;
	}

	fix_airport_rect(hor_zoom, vert_zoom) //: void
	{
		if (vert_zoom > hor_zoom)
		{
			var cx_fixed = this.#extent.width / hor_zoom * vert_zoom;
			this.#location.x -=(cx_fixed - this.#extent.width) / 2;
			this.#extent.width = cx_fixed;
		}
		else
		{
			var cy_fixed = this.#extent.height / vert_zoom * hor_zoom;
			this.#location.y -=(cy_fixed - this.#extent.height) / 2;
			this.#extent.height = cy_fixed;
		}
	}

	get_airport_model_region() //: Region
	{
		var region = new Region();
		for (let airfield of this.#airfields)
		{
			let apoints = airfield.get_region().corner_points;
			for (let j = 0; j < apoints.length; j++)
			{
				let point: Point = apoints[j];
				let x_left = region.location.x - region.extent.width / 2;
				let x_right = region.location.x + region.extent.width / 2;
				let y_top = region.location.y - region.extent.height / 2;
				let y_bottom = region.location.y + region.extent.height / 2;
				let cx_left_shift = x_left - point.x;
				let cx_right_shift = point.x - x_right;
				let cy_top_shift = y_top - point.y;
				let cy_bottom_shift = point.y - y_bottom;
				if (cx_left_shift > 0)
				{
					region.extent.width += cx_left_shift;
					region.location.x -= cx_left_shift / 2;
				}
				else if (cx_right_shift > 0)
				{
					region.extent.width += cx_right_shift;
					region.location.x += cx_right_shift / 2;
				}
				if (cy_top_shift > 0)
				{
					region.extent.height += cy_top_shift;
					region.location.y -= cy_top_shift / 2;
				}
				else if (cy_bottom_shift > 0)
				{
					region.extent.height += cy_bottom_shift;
					region.location.y += cy_bottom_shift / 2;
				}
			}
		}
		return region;
	}

	load_level(level_file) 
	{
		//TODO - load level from... somewhere.
	}

	make_level_xml() //: XML
	{
		var xml_doc = new XML('<level></level>');
		this.#saveGates(xml_doc);
		this.#saveAirfields(xml_doc);
		this.#saveAprons(xml_doc);
		return xml_doc;
	}	
	
	resize(location, extent)
	{
		this.#location = location;
		this.#extent = extent;
	
		//TODO: OnResized.fireOnResized();
	}

	update_wind()
	{
		this.#current_wind.update();
		for (let airfield of this.#airfields)
		{
			airfield.update_wind(this.#current_wind.direction);
		}
	}

//private methods
	#load_airport(xml) //: void
	{
		this.resize(
			new Point(xml.@left, xml.@top), 
			new Size(xml.@width, xml.@height)
		);
		
		if (!this.#thumbnail_mode)
		{
			this.#load_gates(xml.gates[0]);
			this.#load_helipads(xml.helipads[0]);
			this.#load_aprons(xml.aprons[0]);		
		}
		this.#load_runways(xml.runways[0]);
	}
	
	#load_aprons(xml) //: void
	{
		if (!xml || !xml.apron) return;
		
		for (let xml_node of xml.apron)
		{
			this.#aprons.push(SelectableObject.from_xml(xml_node));
		}
	}
		
	#load_gates(xml) //: void
	{
		for (let xml_node of xml.gate)
		{
			let gate = Gate.from_xml(xml_node);
			this.#gates.push(gate);
			
			//TODO: OnGateLoaded.fireOnGateLoaded(gate);
		}
	}

	#load_helipads(xml)
	{
		if (!xml || !xml.helipad) return;
		
		for (let xml_helipad in xml.helipad)
		{
			var helipad = Helipad.from_xml(xml_helipad);
			this.#gates.push(helipad);
			this.#airfields.push(helipad);
			
			//TODO: OnGateLoaded.fireOnGateLoaded(helipad);			
		}
	}	
	
	#load_level_cont()
	{
		//TODO: load level continuation let xml_doc = new XML(this.#url_loader.data);
		//this.#url_loader.close();

		let xml_airport = xml_doc.airport[0];

		if (!xml_airport)
		{
			console.log("Failed to load level: airport tag not found.");
			return;
		}
		
		if (!this.#thumbnail_mode)
		{
			this.#load_weather(xml_doc.weather[0]);
		}
		this.#load_airport(xml_airport);

		//TODO: send level loaded event OnLevelLoaded.fireOnLevelLoaded();
	}
		
	#load_runways(xml)
	{
		if (!xml || !xml.runway) return;		
		
		for (var xml_runway of xml.runway)
		{
			this.#airfields.push(new Runway(xml_runway, this));
		}
	}
	
	#load_weather(xml)
	{
		let dbl_cloud_probability = xml.clouds[0].@probability;
		let xml_wind = xml.wind[0];
		let dbl_wind_variability = xml_wind.@variability;
		let dbl_wind_min_speed = xml_wind.@minSpeed;
		let dbl_wind_max_speed = xml_wind.@maxSpeed;
		
		this.#current_wind = new Wind(dbl_wind_min_speed, dbl_wind_max_speed, dbl_wind_variability);
		this.#cloud_probability = dbl_cloud_probability;
	}
	
	#save_airfields(xml_node) //: void
	{
		let xml_runways = new XML('<runways></runways>');
		xml_node.appendChild(xml_runways);
		
		for (let airfield of this.#airfields)
		{
			let xml_runway = new XML('<runway></runway>');
			xml_runways.appendChild(xml_runway);

			airfield.to_xml(xml_runway);
		}
	}
		
	#save_aprons(xml_node) //: void
	{
		let xml_aprons = new XML('<aprons></aprons>');
		xml_node.appendChild(xml_aprons);
		
		for (let mo_apron of this.#aprons)
		{
			let xml_apron = new XML('<apron></apron>');
			xml_aprons.appendChild(xml_apron);
			
			mo_apron.to_xml(xml_apron);
		}
	}

	#save_gates(xml_node) //: void
	{
		let xml_gates = new XML('<gates></gates>');
		xml_node.appendChild(xml_gates);
		
		for (let gate of this.#gates)
		{
			let xml_gate = new XML('<gate></gate>');
			xml_gates.appendChild(xml_gate);

			gate.to_xml(xml_gate);
		}
	}

	//event handlers
	//TODO: continue level loading of file download finished
	//#url_loader_on_complete(event): void
	//{
	//	this.#load_level_cont();
	//}
}


///////////////////////////////////////////////////////////
//  ScreenManager.as
///////////////////////////////////////////////////////////

class ScreenManager //static
{
	static get #FONT_SIZE_TINY() {return 8};
	static get #FONT_SIZE_SMALL() {return 12};
	static get #FONT_SIZE_MEDIUM() {return 16};
	static get #FONT_SIZE_LARGE() {return 32};
	static #stg_stage = null;

//properties

	static get display_objects_count () //: int
	{
		//TODO
	}

	static stage_size () //: Size
	{
		//TODO: number of objects on the stage
	}
//methods
	//public methods
	static create_frame() //: Size
	{
		//TODO: Remove objects from the stage
		//let i = 0;
		//while (i < stgStage.numChildren) 
		//{
		//	stgStage.removeChildAt(i);
		//}
		
		//return StageSize;
	}
	
	static display_image(display_object, rect, angle = null) 
	{
		//TODO: Add object to stage, set position, size and angle

		// display_object.x = rect.location.x;
		// display_object.y = rect.location.y;
		// if (rect.extent.width >= 0 && rect.extent.height >= 0)
		// {
		// 	display_object.width = rect.extent.width;
		// 	display_object.height = rect.extent.height;
		// }
		
		// if (angle)
		// {
		// 	display_object.rotation = angle.degree;
		// }

		//stgStage.addChild(display_object);
	}
		
	static display_text(
		text, 
		rect, 
		font_size=16, 
		color=0x_ffffff, 
		to_show_background=false, 
		is_input_field=false, 
		is_multiline=true)		
	{	
		//TODO: Display text
		// var txt_field: TextField = new TextField();
		
		// txt_field.autoSize = TextFieldAutoSize.LEFT;
		
		// if (ARect.extent.width >= 0) txt_field.width = ARect.extent.width;
		// if (ARect.extent.height >= 0) txt_field.height = ARect.extent.height;
		// if (ToShowBackground) txt_field.background = true;
		// if (IsInputField) 
		// {
		// 	txt_field.type = TextFieldType.INPUT;
		// 	if (IsMultiline)
		// 	{
		// 		txt_field.wordWrap = true;
		// 		txt_field.multiline = true;
		// 	}
		// }
		
		// txt_field.defaultTextFormat = new TextFormat("Arial", AFontSize, AColor);
		// txt_field.text = AText; 
		// if (ARect is Region)
		// {
		// 	txt_field.autoSize = TextFieldAutoSize.CENTER;
		// 	txt_field.rotation = Region(ARect).Rotation.Degree;
		// 	txt_field.x = ARect.location.x - txt_field.textWidth/2;
		// 	txt_field.y = ARect.location.y - txt_field.textHeight/2;
		// }		
		// else
		// {
		// 	txt_field.x = ARect.location.x;
		// 	txt_field.y = ARect.location.y;
		// }
		// stgStage.addChild(txt_field);
	}
	
	static draw_line(point_array, color, alpha)
	{
		// TODO: Draw line 		
		// if (point_array.length < 2) return;

		// var shp_path: shape = new shape();
		// shp_path.graphics.line_style(1, color, alpha, false, line_scale_mode.none, caps_style.none, null, 3);
	
		// var vdbl_data: vector.<number> = convert_to_int_vector(point_array);
		// var vn_commands: vector.<int> = get_commands(point_array.length);
				
		// shp_path.graphics.draw_path(vn_commands, vdbl_data);
		
		// //sp_frame_buffer.add_child(shp_path);
		// stg_stage.add_child(shp_path);
	}

	static init(stage)
	{
		//stgStage = AStage;
	}
	
//private methods
	static convert_to_int_vector(path) //: Vector.<Number>
	{	
		var vn_result = [];
		for (let pnt of path)
		{
			vn_result.push(pnt.x);
			vn_result.push(pnt.y);
		}
		return vn_result;
	}
		
	static get_commands(length) //: Vector.<int>
	{
		
		// var vn_result = [];	
		// vn_result.push(GraphicsPathCommand.MOVE_TO);
		// for (var i: int = 1; i < ALength; i++)
		// 	vn_result.push(GraphicsPathCommand.LINE_TO);
		// return vn_result;
	}
}

class Controllers extends Enum 
{
	static GAME_CONTROLLER = new Controllers("GAME_CONTROLLER", 0);
	static EDIT_CONTROLLER = new Controllers("EDIT_CONTROLLER", 1);
	static MENU_CONTROLLER = new Controllers("MENU_CONTROLLER", 2);

	static values() {
	  return [this.GAME_CONTROLLER, this.EDIT_CONTROLLER, this.MENU_CONTROLLER];
	}
}

class DisplayMode extends Enum
{
	static #NORMAL_PAUSE = 48;
	static #LONG_PAUSE = 100;	

	static #PAUSE = [0, 0, 0, 0, 0, NORMAL_PAUSE, NORMAL_PAUSE, 0, 0, 0, LONG_PAUSE];
	static #AIRPORT_SHOWN = [true, false, false, false, false, true, true, false, false, true, false];
	static #BANNER_SHOWN = [false, true, true, true, true, false, false, false, false, false, true];	
	static #MENU_SHOWN = [false, false, false, false, false, false, false, true, true, false, false];
	static #SPLASH_SCREEN = [false, false, false, false, false, false, false, false, false, false, true];
	static #TITLE_COLORS = [null, Colors.Red, Colors.Green, Colors.White, Colors.Blue, null, null, Colors.Blue, Colors.Blue, null, Colors.Blue];
	static #TITLES = [null, "Mission failed", "Level completed", "Level ", "Admiro" , null, null, null, null, null, null];

 //property fields
	//modes
    static PLAY = new DisplayMode("PLAY", 0);
	static LEVEL_FAILED_BANNER = new DisplayMode("LEVEL_FAILED_BANNER", 1);
	static LEVEL_COMPLETE_BANNER = new DisplayMode("LEVEL_COMPLETE_BANNER", 2);	
	static LEVEL_START_BANNER = new DisplayMode("LEVEL_START_BANNER", 3);	
	static ABOUT_BANNER = new DisplayMode("ABOUT_BANNER", 4);
    static CRASH_PAUSE = new DisplayMode("CRASH_PAUSE", 5);	
	static MISSION_COMPLETE_PAUSE = new DisplayMode("MISSION_COMPLETE_PAUSE", 6);
	static BOX_MENU = new DisplayMode("BOX_MENU", 7);	
	static LEVEL_MENU = new DisplayMode("LEVEL_MENU", 8);	
	static EDIT = new DisplayMode("EDIT", 9);
	static SPLASH_SCREEN = new DisplayMode("SPLASH_SCREEN", 10);

	static values() {
	  return [
	  	this.PLAY, 
	  	this.LEVEL_FAILED_BANNER, 
	  	this.LEVEL_COMPLETE_BANNER, 
	  	this.LEVEL_START_BANNER, 
	  	this.ABOUT_BANNER, 
	  	this.CRASH_PAUSE, 
	  	this.MISSION_COMPLETE_PAUSE, 
	  	this.BOX_MENU, 
	  	this.LEVEL_MENU,
	  	this.EDIT,
	  	this.SPLASH_SCREEN
	  ];
	}

//properties
	get airport_shown() //: Boolean
    {
    	return !!DisplayMode.#AIRPORT_SHOWN[this.#value];
    }

	get banner_shown() //: Boolean
    {
    	return !!DisplayMode.#BANNER_SHOWN[this.#value];
    }	
	
    get color() 
    {
		return DisplayMode.TITLE_COLORS[this.#value];
    }
	
	get id() //: int
    {
    	return 1 << this.#value;
    }
	
    get index() //: int
    {
    	return this.#value;
    }

	get is_splash_screen() //: Boolean
    {
    	return !!DisplayMode.#SPLASH_SCREEN[this.#value];
    }		
	
	get menu_shown() //: Boolean
    {
    	return !!DisplayMode.#MENU_SHOWN[this.#value];
    }		
	
	get pause() //: Number
    {
    	return DisplayMode.#PAUSE[this.#value];
    }

    get title() //: String
    {
    	return DisplayMode.#TITLES[this.#value];
    }

	get to_string() //: String
    {
    	return this.#name;
    }
}


///////////////////////////////////////////////////////////
//  Profiler.as
///////////////////////////////////////////////////////////

class Profiler //static
{
	static #watches = {};

//public methods
	static checkin(name)
    {
		if (!Profiler.#watches[name])
			watches[name] = {CheckinTime: new Date(), Watch: 0}
		else
		{
			var watch = Profiler.#watches[name];
			if (watch.CheckinTime.getTime() == 0)
			{
				watch.CheckinTime = new Date();
				//console.log(">> " + name + " checked in");
			}
			else
				console.log("Reccurent checkin for " + name);
		}
    }

    static checkout(name)
    {
		if (Profiler.#watches[name])
		{
			var watch = Profiler.#watches[name];
			if (watch.CheckinTime.getTime() == 0)
				console.log("Checkout without checkin for " + name);
			else
			{
				var dt_time = new Date();
				watch.Watch += (dt_time.getTime() - watch.CheckinTime.getTime());
				watch.CheckinTime = new Date(0);
				//console.log("<< " + name + " checked out");
			}
		}
		else
			console.log("Checkout without checkin for " + name);
    }
	
	static get_watch(name) //: String
	{
		var str_report = name + " : ";
		if (!Profiler.#watches[name]) 
			str_report += "not found."
		else
		{
			var watch = Profiler.#watches[name];
			str_report += watch.Watch + "ms";
			if (watch.CheckinTime.getTime() != 0)
				str_report += " and running";
		}
		return str_report;
	}
	
	static reset()
    {
		Profiler.#watches = {};
    }	
}

///////////////////////////////////////////////////////////
//  GameProgress.as
///////////////////////////////////////////////////////////
class GameProgress //static
{
//public fields & consts		
	static get IS_BOSS_MODE_ON(){return true};
	static get BOX_COUNT(){return 3};
	static get BOX_FULL_COMPL_REQ(){return 0.99}; //0.99
	static get BOX_PASS_REQ(){return 0.75}; //0.75
	static get LEVEL_COUNT(){return 27};
	
	//public fields
	static on_box_opened = new CustomDispatcher();
//private fields & consts

	//private consts
	static #BOX0_FIRST_LEVEL = 1;
	static #BOX0_LAST_LEVEL = 9;
	static #BOX1_FIRST_LEVEL = 10;
	static #BOX1_LAST_LEVEL = 18;
	static #BOX2_FIRST_LEVEL = 19;
	static #BOX2_LAST_LEVEL = 27;

	//property fields
	static #level = 1;
	static #level_completion = [];
	static #points = 0;
	static #newly_opened_box = -1;

	//other fields
	static #box_first_levels = null; 
	static #box_last_levels = null;

//properties
	static get box()
	{
		return GameProgress.get_box_for_level(this.#level);
	}
	
	static get box_first_level()
    {
		return GameProgress.#box_first_levels[GameProgress.box];
    }
	
	static get box_last_level()
    {
		return GameProgress.#box_last_levels[GameProgress.box];
    }
	
	static get box_passed()
	{
		return GameProgress.get_box_progress(GameProgress.box) >= 1;
	}

	static get is_last_box()
	{
		return GameProgress.get_box_for_level(GameProgress.#level) == GameProgress.BOX_COUNT - 1;
	}
	
	static get level() //: int
    {
    	return GameProgress.#level;
    }

	static get level_completion() //: Vector.<int>
	{
		return GameProgress.#level_completion;
	}	
	
	static get newly_opened_box() //: int
	{
		return GameProgress.#newly_opened_box;
	}	
	
	static get points() //: int
    {
    	return GameProgress.#points;
    }	
	
//methods
	//public methods
	static accept_level_result(result)
	{
		let box = GameProgress.box;
		if (GameProgress.#newly_opened_box == n_box)
		{
			GameProgress.#newly_opened_box = -1;
		}
		let progress_before = GameProgress.get_box_progress(box);
		GameProgress.#level_completion[GameProgress.#level - 1] = Math.max(result, 
			GameProgress.#level_completion[GameProgress.#level - 1]); 
		let progress_after = get_box_progress(box);
		if (box + 1 < GameProgress.BOX_COUNT && progress_before < 1 && progress_after >= 1) {
			GameProgress.#newly_opened_box = box + 1;
			//OnBoxOpened.fireOnBoxOpened(n_box + 1);
			//TODO: Fire on box open event
		}
	}
	
	static add_points(point_qty)
	{
		GameProgress.#points += point_qty;
	}
	
	static get_box_for_level(level_number) //: int
	{
		if (!GameProgress.#box_first_levels || !GameProgress.#box_last_levels) GameProgress.#init_box_info();
	
		for(let box = 0; box < GameProgress.BOX_COUNT; box++)
			if (level_number >= GameProgress.#box_first_levels[box] 
				&& level_number <= GameProgress.#box_last_levels[box])
				return box;
		return -1;
	}	
	
	//result >= 1  - box passed
	static get_box_progress(box_number) //: Number
	{
		if (box_number < 0 || box_number >= GameProgress.BOX_COUNT) return 0;
		if (!GameProgress.#box_first_levels || !GameProgress.#box_last_levels) GameProgress.#initBoxInfo();
		
		let first_level_number = GameProgress.#box_first_levels[box_number];
		let last_level_number = GameProgress.#box_last_levels[box_number];
		let target_sum = (last_level_number - first_level_number + 1) * 100 
			* ((box_number < GameProgress.BOX_COUNT - 1) ? GameProgress.BOX_PASS_REQ : GameProgress.BOX_FULL_COMPL_REQ);
		let progress_sum = 0;
		for (let i = first_level_number; i <= last_level_number; i++)
		{
			if (i > GameProgress.LEVEL_COUNT) break;
			
			progress_sum += GameProgress.#level_completion[i - 1];
		}	
		return progress_sum / target_sum;
	}
	
	static get_first_level_for_box(box_number)
	{
		if (!GameProgress.#box_first_levels || !GameProgress.#box_last_levels) GameProgress.#init_box_info();
		return GameProgress.#box_first_levels[box_number];
	}
	
	static next_level()
	{
		GameProgress.#level++;
	}

	static reset()
	{
		GameProgress.#level = 1;
	}

	static select_specified_level (level_number)
	{
		GameProgress.this.#level = level_number;
	}	
	
	
//private methods
	static #init_box_info()
	{
		GameProgress.box_first_levels = [];
		GameProgress.box_last_levels = [];
		GameProgress.box_first_levels[0] = GameProgress.#BOX0_FIRST_LEVEL;
		GameProgress.box_last_levels[0] = GameProgress.#BOX0_LAST_LEVEL;
		GameProgress.box_first_levels[1] = GameProgress.#BOX1_FIRST_LEVEL;
		GameProgress.box_last_levels[1] = GameProgress.#BOX1_LAST_LEVEL;
		GameProgress.box_first_levels[2] = GameProgress.#BOX2_FIRST_LEVEL;
		GameProgress.box_last_levels[2] = GameProgress.#BOX2_LAST_LEVEL;
	}
}

///////////////////////////////////////////////////////////
//  MenuController.as
///////////////////////////////////////////////////////////

class MenuController implements IController //singleton
{
//private fields & consts
	thumbnail_models = []; // Vector.<Airport>;
	static #controller_instance = []//: MenuController;
	
//properties
	get thumbnail_models() //:Vector.<Airport>
	{
		return this.#thumbnail_models;
	}

//methods
	//constructor
	//private constructors not supported by actionscript
	//use get_instance instead!	
	constructor ()
	{
		this.#load_thumbnail_models();
	}		

//public methods
	get_controller_type() //: int
	{
		return Controllers.MENU_CONTROLLER;
	}	
	
	static get_instance() //: MenuController
	{
		if (!MenuController.#controller_instance)
		{
			MenuController.#controller_instance = new MenuController();
		}
		return MenuController.#controller_instance;
	}
		
	process_dispatcher_event(event_type, param_obj=null)//: Boolean
	{
		switch (event_type)
		{
			case OutcomingDispatcherEventTypes.BACK_TO_BOXES:
				ControlDispatcher.current_display_mode = DisplayMode.BOX_MENU;
				return true;
				
			case OutcomingDispatcherEventTypes.BOX_OPEN:
				if (!param_obj.IsBoxLocked)
				{
					ControlDispatcher.current_display_mode = DisplayMode.LEVEL_MENU; 
					GameProgress.select_specified_level(param_obj.OpeningLevel);
					return true;
				}
				break;											
		}
		
		return false;
	}
	
	run() //: void
    {
	}
	
//private methods
	#load_thumbnail_models()
	{
		this.#thumbnail_models = [] //new Vector.<Airport>(GameProgress.N_LEVEL_COUNT, true);
		for (let i = 1; i <= GameProgress.LEVEL_COUNT; i++)
		{
			let ap_model = new Airport(true);
			this.#thumbnail_models[i-1] = ap_model;
			//TODO: Loading level
			//ap_model.load_level("levels/Level" + i.to_string() + ".xml");		
		}
	}
}


///////////////////////////////////////////////////////////
//  MenuView.as
///////////////////////////////////////////////////////////

class MenuView
{
	static #CX_PROGRESS = 78.8; 
	static #CY_PROGRESS = 20.50;
	static #CY_PROGRESS_BOTTOM_MARGIN = 6;
	static #CY_THUMBNAIL_RELATIVE_TO_ICON = 0.8;
	static #BOX_CLOSED_ICON_HEIGHT_RATIO= 1.13;	
	static #HORIZONTAL_MARGIN = 0.045; //relative to GameZone height
	static #SPACE_ICON_RATIO = 0.5; //отношение места между иконками к размеру иконки
	static #THUMBNAIL_MINIATURE_SPACING = 0.1; //отношение полей миниатюры к размеру пиктограммы
	static #VERTICAL_MARGIN = 0.066; //relative to GameZone height
	static #BOX_MENU_COLUMNS = GameProgress.N_BOX_COUNT;
	static #BOX_MENU_ROWS = 1;
	static #LEVEL_MENU_COLUMNS = 3;
	static #LEVEL_MENU_ROWS = 3;
	static #SPRITE_NAME1 = "Box";
	static #SPRITE_NAME2 = "ThumbnailImage";
	static #X_PROGRESS = 98.60; 
	static #Y_PROGRESS = 155.65; 
//methods
	static display()
	{
		Profiler.checkin("menu");
		var is_box_menu = ControlDispatcher.current_display_mode == DisplayMode.BOX_MENU;
		var obj_params = MenuView.#get_menu_parameters(is_box_menu);

		var n_item_number = is_box_menu ? -1 : GameProgress.box_first_level - 1;
		let n_item_last = is_box_menu ? GameProgress.BOX_COUNT - 1 : GameProgress.box_last_level;
		for (let y = 0; y < obj_params.IconRows; y++)
		{
			for (let x = 0; x < obj_params.IconColumns; x++)
			{
				if (++n_item_number > n_item_last) break;
				
				var rect_icon = new Rect(
					new Point(
						obj_params.HorizontalMargin + (obj_params.IconWidth + obj_params.HorizontalSpace)*x, 
						obj_params.VerticalMargin + FrameBuilder.info_panel_rect.extent.height + (obj_params.IconHeight + obj_params.VerticalSpace)*y
					), 
					new Size(obj_params.IconWidth, obj_params.IconHeight)
				)
				MenuView.display_box_icon(is_box_menu, n_item_number, rect_icon, obj_params);
			}
		}		
		Profiler.checkout("menu");
	}

	static display_box_icon(is_box, item_number, icon_rect, box_params=null)
	{
		if (!box_params)
		{
			var box_params = MenuView.#get_menu_parameters(is_box);
		}
		var dbl_progress = is_box ? GameProgress.get_box_progress(item_number) : GameProgress.level_completion[item_number-1] / 100;
		// TODO: sprite creation
		//var sp_icon_frame = (dbl_progress >= 1) ? new BoxCompleteImage() : new BoxOpenImage();				
		box_params.HorizontalZoom = icon_rect.extent.width / sp_icon_frame.width;
		box_params.VerticalZoom = icon_rect.extent.height / sp_icon_frame.height;
		
		MenuView.display_progress(dbl_progress, icon_rect, box_params);	
		ScreenManager.display_image(sp_icon_frame, icon_rect, new Angle());		
		MenuView.display_thumbnail(is_box, item_number, icon_rect, box_params);
			
		if (is_box && (!GameProgress.IS_BOSS_MODE_ON && item_number != 0 
			&& GameProgress.get_box_progress(item_number - 1) < 1
			|| item_number == GameProgress.newly_opened_box))
		{
			//TODO Sprite creation
			//var sp_lock = (item_number == GameProgress.newly_opened_box) ? new LockOpenedImage() : new LockClosedImage();
			ScreenManager.display_image(sp_lock, icon_rect, new Angle());
		}
	}
	
	static process_event(event) //: Boolean
	{
		//TODO Event processing
		//if (event is MouseEvent && event.type == MouseEvent.CLICK)
		// {
		// 	TODO Event processing
		// 	var mouse_event: MouseEvent = MouseEvent(event);
			
		// 	switch (ControlDispatcher.current_display_mode)
		// 	{
		// 		case DisplayMode.LEVEL_MENU:
		// 			return ControlDispatcher.dispatch_view_event(IncomingDispatcherEventTypes.MENU_LEVEL_SELECT, 
		// 				{LevelNumber: MenuView.#get_level_by_coords(mouse_event.stageX, mouse_event.stageY)});
		// 			break;
		// 		case DisplayMode.BOX_MENU:
		// 			return ControlDispatcher.dispatch_view_event(IncomingDispatcherEventTypes.N_MENU_BOX_SELECT, 
		// 				MenuView.get_box_by_coords(mouse_event.stageX, mouse_event.stageY));					
		// 			break;				
		// 		default: return false;
		// 	}
		// }
		return false;
	}
	
//private methods
	static #display_airfield(airfield, thumbnail_rect, zoom_factor, model_center)
	{
		if (!airfield.is_runway) return;
		var scr_region = airfield.get_region().clone_region();
		scr_region.extent.width /= zoom_factor;
		scr_region.extent.height /= zoom_factor;
		scr_region.location.x = (scr_region.location.x - model_center.x) / zoom_factor 
			+ thumbnail_rect.location.x + thumbnail_rect.extent.width/2;
		scr_region.location.y = (scr_region.location.y - model_center.y) / zoom_factor 
			+ thumbnail_rect.location.y + thumbnail_rect.extent.height/2;
		//TODO: Sprite creation
		//ScreenManager.display_image(new RunwayThumbnailImage(), scr_region, airfield.active_course);
	}
	
	static #display_progress(progress, icon_rect, params)
	{
		progress = Math.min(progress, 1);
		//TODO: Sprite creation
		//var sp_bg: Sprite = new MenuProgressBackgroundImage();	
		// var rect_bg: Rect = new Rect(
		// 	new Point(
		// 		icon_rect.location.x + MenuView.#X_PROGRESS * params.HorizontalZoom, 
		// 		icon_rect.location.y + MenuView.#Y_PROGRESS * params.VerticalZoom
		// 	), 
		// 	new Size(MenuView.#CX_PROGRESS * params.HorizontalZoom, MenuView.#CY_PROGRESS * params.VerticalZoom)
		// );
				
		// var sp_filler = new MenuProgressFillerImage();
		// var rect_filler = rect_bg.clone();
		// rect_filler.extent.width *= progress;
		// ScreenManager.display_image(sp_bg, rect_bg, new Angle());
		// ScreenManager.display_image(sp_filler, rect_filler, new Angle());
	}

	static #display_thumbnail(is_box, item_number, icon_rect, params)
	{
		var rect_thumbnail = icon_rect.clone();
		rect_thumbnail.extent.width *= MenuView.#CY_THUMBNAIL_RELATIVE_TO_ICON;
		let dbl_margin = (icon_rect.extent.width - rect_thumbnail.extent.width) / 2;
		rect_thumbnail.location.x += dbl_margin;
		rect_thumbnail.location.y += dbl_margin;
		rect_thumbnail.extent.height -= dbl_margin*2 + MenuView.#CY_PROGRESS * params.VerticalZoom 
			+ FrameBuilder.adapt_to_frame(MenuView.#CY_PROGRESS_BOTTOM_MARGIN);

		//TODO: Sprite creation and showing
		//ScreenManager.display_image(new ThumbnailBoxImage, rect_thumbnail, new Angle());

		rect_thumbnail.location.x += rect_thumbnail.extent.width * MenuView.#THUMBNAIL_MINIATURE_SPACING;
		rect_thumbnail.location.y += rect_thumbnail.extent.height * MenuView.#THUMBNAIL_MINIATURE_SPACING;
		rect_thumbnail.extent.width *= (1 - 2*MenuView.#THUMBNAIL_MINIATURE_SPACING);
		rect_thumbnail.extent.height *= (1 - 2*MenuView.#THUMBNAIL_MINIATURE_SPACING);
		
		if (is_box) {
			//TODO: Parameterized sprite creation
			//var classSprite: Class = getDefinitionByName(STR_SPRITE_NAME1 + item_number + STR_SPRITE_NAME2) as Class;
			//var clip: Sprite = new classSprite();
			//ScreenManager.display_image(clip, rect_thumbnail);
		}	
		else {
			let airport = MenuController.get_instance().thumbnail_models[item_number - 1];
			var rg_model = airport.get_airport_model_region();
			var dbl_zoom = Math.max(rg_model.extent.width / rect_thumbnail.extent.width, 
				rg_model.extent.height / rect_thumbnail.extent.height);

			for (var airfield of airport.airfields)	{
				MenuView.display_airfield(airfield, rect_thumbnail, dbl_zoom, rg_model.location);
			}
		}
	}

	static #get_box_by_coords(x, y) //: Object
	{
		var obj_level_params = MenuView.#get_menu_parameters(new Boolean(false));
		var obj_result = {BoxNumber: -1, OpeningLevel: -1, IsBoxLocked: true};
		var n_box_no = MenuView.#get_menu_icon_number_by_coords(true, x, y);
		if (n_box_no >= 0 && n_box_no < GameProgress.BOX_COUNT)
		{
			obj_result.BoxNumber = n_box_no;
			obj_result.OpeningLevel = GameProgress.get_first_level_for_box(n_box_no);
			obj_result.IsBoxLocked = !GameProgress.IS_BOSS_MODE_ON && n_box_no > 0 && GameProgress.get_box_progress(n_box_no - 1) < 1;
		}
		return obj_result;
	}

	static #get_level_by_coords(x, y) //: int
	{
		var obj_params = MenuView.#get_menu_parameters(new Boolean(false));

		var n_icon_number = MenuView.#get_menu_icon_number_by_coords(false, x, y);
		var n_level_number = GameProgress.box_first_level + n_icon_number;
		if (n_icon_number >= 0 && n_level_number <= GameProgress.box_last_level)
			return n_level_number;
		else
			return -1;
	}	
	
	static #get_menu_icon_number_by_coords(is_box_menu, x, y) //: int
	{
		var obj_params = MenuView.#get_menu_parameters(is_box_menu);
		
		let n_row: int = Math.floor((y - FrameBuilder.info_panel_rect.extent.height - obj_params.VerticalMargin)/(obj_params.IconHeight + obj_params.VerticalSpace));
		if (y - FrameBuilder.info_panel_rect.extent.height - obj_params.VerticalMargin - (obj_params.IconHeight + obj_params.VerticalSpace) * n_row > obj_params.IconHeight) 
		{
			return -1;
		}
			
		let n_column = Math.floor((x - obj_params.HorizontalMargin)/(obj_params.IconWidth + obj_params.HorizontalSpace));
		if (x - obj_params.HorizontalMargin - (obj_params.IconWidth + obj_params.HorizontalSpace) * n_column > obj_params.IconWidth) 
		{
			return -1;
		}
		
		return n_row * obj_params.IconColumns + n_column;
	}

	static #get_menu_parameters(is_box_menu)
	{
		var obj_params = {};		
		if (is_box_menu) {
			obj_params.IconColumns = MenuView.#BOX_MENU_COLUMNS;
			obj_params.IconRows = MenuView.#BOX_MENU_ROWS;
		}
		else {
			obj_params.IconColumns = MenuView.#LEVEL_MENU_COLUMNS;
			obj_params.IconRows = MenuView.#LEVEL_MENU_ROWS;
		}		
		obj_params.HorizontalMargin = MenuView.#HORIZONTAL_MARGIN*FrameBuilder.game_zone_rect.extent.width;
		obj_params.VerticalMargin = MenuView.#VERTICAL_MARGIN*FrameBuilder.game_zone_rect.extent.height;
		var cx_menu = FrameBuilder.game_zone_rect.extent.width * (1 - MenuView.#HORIZONTAL_MARGIN * 2);
		var cy_menu = FrameBuilder.game_zone_rect.extent.height * (1 - MenuView.#VERTICAL_MARGIN * 2);
		var cx_icon =  cx_menu / ((MenuView.#SPACE_ICON_RATIO + 1)*(obj_params.IconColumns - 1) + 1);;
		var cy_icon =  cy_menu / ((MenuView.#SPACE_ICON_RATIO + 1)*(obj_params.IconRows - 1) + 1);		
		if (cx_icon > cy_icon) {
			obj_params.HorizontalSpace = (cx_menu - cy_icon*obj_params.IconColumns)/(obj_params.IconColumns - 1);
			if (obj_params.HorizontalSpace > cy_icon) {
				obj_params.HorizontalSpace = cy_icon;
				obj_params.HorizontalMargin += (cx_menu - cy_icon*(obj_params.IconColumns*2 - 1))/2;
			}
			obj_params.VerticalSpace = cy_icon * MenuView.#SPACE_ICON_RATIO;
			obj_params.IconWidth = cy_icon;
			obj_params.IconHeight = cy_icon;
		}
		else {
			obj_params.HorizontalSpace = cx_icon * MenuView.#SPACE_ICON_RATIO;
			obj_params.VerticalSpace = (cy_menu - cx_icon*obj_params.IconRows)/(obj_params.IconRows - 1);
			if (obj_params.VerticalSpace > cx_icon) {
				obj_params.VerticalSpace = cx_icon;
				obj_params.VerticalMargin += (cy_menu - cx_icon*(obj_params.IconRows*2 - 1))/2;
			}
			obj_params.IconWidth = cx_icon;
			obj_params.IconHeight = cx_icon;
		}
		return obj_params;
	}
}


///////////////////////////////////////////////////////////
//  HintPanelView.as
///////////////////////////////////////////////////////////


class HintPanelView //static
{
//public fields & consts		
	//events
	static on_hidden = new CustomDispatcher();
	static on_hiding = new CustomDispatcher();
	static on_shown = new CustomDispatcher();

//private fields & consts
	//private consts
	static #CX_HINT_MARGIN = 0.1; //of hint window size
	static #HINT_FONT_SIZE = 20;
	static #SHOW_RATE = 0.05;
	static #FORCED_SHOW_PERIOD = 1;
	static #HIDDEN_PERIOD = 4000;
	static #SHOWN_PERIOD = 30000;
	
	//panel states in order of occurrence
	static #STATE_HIDDEN = 0;
	static #STATE_SHOWING = 1;
	static #STATE_SHOWN = 2;
	static #STATE_HIDING = 3;
	
	//property fields
	static #clip_ids = [] //: Vector.<String> = new Vector.<String>();
	static #hints = [] //: Vector.<String> = new Vector.<String>();

	//other fields
	static #shown_part = 0;
	static #hint_to_show_index = 0;
	static #state = HintPanelView.#STATE_HIDDEN;
	static #target_rect = null;  
	//TODO: Timer
	static #hint_timer = null; // new Timer(100); 
//properties
	static get clip_ids () //: Vector.<String>
	{
		return HintPanelView.#clip_ids;
	}

	static get hints () //: Vector.<String>
	{
		return HintPanelView.#hints;
	}

	static get is_shown () //: Boolean
	{
		return HintPanelView.#state != HintPanelView.#STATE_HIDDEN;
	}

//public methods
	static display()
	{
		Profiler.checkin("hint");
		try
		{
			if (HintPanelView.#state == HintPanelView.#STATE_HIDDEN) return;
			
			//TODO: Creating and showing sprite
			//var hp = new HintPanel();
			//hp.HintTextField.text = HintPanelView.#hints[HintPanelView.#hint_to_show_index];
			//hp.HintTextField.setTextFormat(new TextFormat("Arial", FrameBuilder.adaptToFrame(HintPanelView.#HINT_FONT_SIZE), Colors.White));
			//ScreenManager.displayImage(hp, getHintPanelRect(), new Angle());

			//TODO: Creating and showing sprite		
			// var str_class_name = HintPanelView.#clip_ids[HintPanelView.#hint_to_show_index];
			// if (str_class_name != "")
			// {
			// 	var classClip = getDefinitionByName(str_class_name) as Class;
			// 	var clip = new classClip(); //: MovieClip
			// 	var rect_panel = HintPanelView.#get_hint_panel_rect();
				
			// 	ScreenManager.display_image(
			// 		clip, 
			// 		new Rect(
			// 			rect_panel.location.add(new Point(rect_panel.extent.width*HintPanelView.#CX_HINT_MARGIN, hp.AnimationPlaceholder.y)), 
			// 			FrameBuilder.adapt_size_to_frame(new Size(hp.AnimationPlaceholder.width, hp.AnimationPlaceholder.height))
			// 		), 
			// 		new Angle()
			// 	);
			// }
		}
		finally
		{
			Profiler.checkout("hint");
		}
	}

	//GameController use it on display mode change
	static hide(is_forced_hide=false)
	{
		switch(HintPanelView.#state)
		{
			case HintPanelView.#STATE_HIDDEN:
			case HintPanelView.#STATE_HIDING:
				return;
			default: 
				HintPanelView.#state = HintPanelView.#STATE_SHOWN;
				HintPanelView.#control_state();
		}
	}

	static process_event(event) //: Boolean
	{
		//TODO: Event processing
		// if (event is MouseEvent && event.type == MouseEvent.CLICK)
		// {
		// 	let mouse_event = MouseEvent(event);
		// 	let point = new Point(mouse_event.stageX, mouse_event.stageY);
		// 	if (HintPanelView.is_shown && HintPanelView.#is_inside(point))
		// 	{
		// 		HintPanelView.hide();
		// 		return true;
		// 	}
		// }
		//else if (event.type == Core.DISPLAY_MODE_CHANGE)
			// {
			// 	if(ControlDispatcher.current_display_mode != DisplayMode.PLAY) {
			// 		HintPanelView.reset();				
			// 	}
			// }

		return false;
	}	

	static reset()
	{
		HintPanelView.#hints.length = [];
		HintPanelView.#clip_ids = [];
		HintPanelView.#hint_to_show_index = 0;
		HintPanelView.#shown_part = 0;
		HintPanelView.#state = HintPanelView.#STATE_HIDING;
		HintPanelView.#control_state();
	}
	
	static show(is_forces_show=false)
	{
		if (HintPanelView.#state != HintPanelView.#STATE_HIDDEN) return false;
		if (!is_forces_show || HintPanelView.#hint_to_show_index >= HintPanelView.#hints.length) HintPanelView.#hint_to_show_index = 0;
		
		HintPanelView.#target_rect = FrameBuilder.frame_rect.clone();
		HintPanelView.#target_rect.extent.height /= 2;
		HintPanelView.#target_rect.location.y = HintPanelView.#target_rect.extent.height;
		
		//TODO: Timer
		// HintPanelView.#hint_timer.addEventListener(TimerEvent.TIMER, HintPanelView.#on_timer);
		// HintPanelView.#hint_timer.delay = is_forces_show ? HintPanelView.#FORCED_SHOW_PERIOD : HintPanelView.#HIDDEN_PERIOD;
		// HintPanelView.#hint_timer.start();
		
		return true;
	}

//private methods
	static #control_state()
	{
		switch (HintPanelView.#state)
		{
			case HintPanelView.#STATE_HIDDEN:
				if (HintPanelView.#hint_to_show_index < HintPanelView.#hints.length)
				{
					HintPanelView.#state = HintPanelView.#STATE_SHOWING;
					HintPanelView.#hint_timer.delay = 1000 / Core.FRAME_RATE;
				}
				//TODO: Timer
				//else
					//HintPanelView.#hint_timer.stop();
				return;
			case HintPanelView.#STATE_SHOWING:
				HintPanelView.#shown_part += HintPanelView.#SHOW_RATE;
				if (HintPanelView.#shown_part >= 1)
				{
					HintPanelView.#shown_part = 1;
					HintPanelView.#state = HintPanelView.#STATE_SHOWN;
					HintPanelView.#hint_timer.delay = HintPanelView.#SHOWN_PERIOD;
					//TODO: firing event
					//HintPanelView.on_shown.fireOnShown();
				}
				break;
			case HintPanelView.#STATE_SHOWN:
				HintPanelView.#state = HintPanelView.#STATE_HIDING;
				//TODO: Timer 
				//HintPanelView.#hint_timer.delay = 1000 / Core.FRAME_RATE;
				//TODO: firing event
				//HintPanelView.on_hiding.fireOnHiding();
				break;
			case HintPanelView.#STATE_HIDING:
				HintPanelView.#shown_part -= HintPanelView.#SHOW_RATE;
				if (HintPanelView.#shown_part <= 0)
				{
					HintPanelView.#shown_part = 0;
					HintPanelView.#state = HintPanelView.#STATE_HIDDEN;
					HintPanelView.#hint_to_show_index++;
					HintPanelView.#hint_timer.delay = HintPanelView.#HIDDEN_PERIOD;
					//TODO: firing event
					//HintPanelView.on_hidden.fireOnHidden();
				}
				break;
		}
	}
	
	static #get_hint_panel_rect() //: Rect
	{
		var dbl_frame_bottom = FrameBuilder.frame_rect.extent.height;
		var rect = HintPanelView.#target_rect.clone();
		rect.location.y = dbl_frame_bottom - (dbl_frame_bottom - rect.location.y) * HintPanelView.#shown_part;
		
		return rect;
	}
	
	static #is_inside(location) //: Boolean
	{
		let rect = HintPanelView.#get_hint_panel_rect();
		return rect.is_inside(location);
	}
	
	//event handlers
	static #on_timer(event) 
	{
		HintPanelView.#control_state();
	}
}


///////////////////////////////////////////////////////////
//  ToolBarItem.as
///////////////////////////////////////////////////////////
class ToolBarItem extends Rect
{
//property fields
	#alignment = 0;
	#gravity = 0;
	#pressed = false;
	
//other fields
	#normalImage = null; //: Sprite;
	#pressedImage = null; //: Sprite;

//properties
	get alignment () //: int
	{
		return this.#alignment;
	}

	set alignment (alignment)
	{
		this.#alignment = alignment;
	}
	
	get gravity () //: Number
	{
		return this.#gravity;
	}
	
	set gravity (value)
	{
		this.#gravity = value;
	}	
	
	get pressed () //: Boolean
	{
		return this.#pressed;
	}
	
	set pressed (value)
	{
		this.#pressed = value;
	}

//constructor
	constructor (size, alignment, gravity, normal_image, pressed_image=null)
	{
		super(new Point(), size);
		this.on_click = new ToolBarEventDispatcher();
		this.on_pressed = new ToolBarEventDispatcher();
		this.on_released = new ToolBarEventDispatcher();
		this.on_paint = new ToolBarEventDispatcher();
		this.#gravity = gravity;
		this.#alignment = alignment;
		this.#normal_image = normal_image;
		this.#pressed_image = pressed_image;
	}		

//public methods
	display(offset)
	{
		var rect = this.clone();
		rect.location = rect.location.add(offset);
		let n_state = this._display_hook();
		var sp_image = null; //: Sprite;
		if (n_state == 0) 
		{
			sp_image = this.#pressed ? this.#pressedImage : this.#normalImage;
		}
		else 
		{
			sp_image = (n_state > 0) ? this.#pressedImage : this.#normalImage;
		}
		
		if (sp_image)
		{
			//TODO: Displaying image
			//ScreenManager.display_image(sp_image, rect);
		}
		else
		{
			this.on_paint.fire_on_paint(this);
		}
	}

	process_event(event_type, location)
	{
		//TODO: Events
		// switch(event_type) {
		// 	case MouseEvent.CLICK:
		// 		if (this.is_inside(location))
		// 		{
		// 			this._on_click_hook();
		// 			this.on_click.fire_on_click(this);
		// 		}
		// 		break;
		// 	case MouseEvent.MOUSE_UP:
		// 		if (this.#pressed)
		// 		{
		// 			this.#pressed = false;
		// 			on_released.fire_on_released(this)
		// 		}
		// 		break;
		// 	case MouseEvent.MOUSE_DOWN:
		// 		if (this.is_inside(location))
		// 		{
		// 			this.#pressed = true;
		// 			this.on_pressed.fire_on_pressed(this);
		// 		}
		// 		break;
		//}
	}
		
//protected methods
	//function returns 1 if the button should be displayed pressed
	//function returns -1 if the button should be displayed unpressed	
	//function returns 0 if makes no decision on that
	_display_hook() 
	{
		return 0;
	}

	_on_click_hook()
	{
		return;
	}
}


///////////////////////////////////////////////////////////
//  ToolBar.as
///////////////////////////////////////////////////////////

class ToolBar extends Rect
{
//public consts		
	static get ALIGNMENT_LEFT() {return 0};
	static get ALIGNMENT_CENTER() {return 1};
	static get ALIGNMENT_RIGHT() {return 2};

//private consts
	#HORIZONTAL_MARGIN = 1/10; //of toolbar width
	#VERTICAL_MARGIN = 1/12; //of toolbar height

//property fields
	#center_aligned_items = []; // new Vector.<ToolBarItem>;
	#left_aligned_items = []; // new Vector.<ToolBarItem>;
	#right_aligned_items = [] //new Vector.<ToolBarItem>;

//constructor
	constructors (location=null, extent=null)
	{
		super(location, extent);
	}		

//public methods
	add_item(item)
	{
		switch(item.alignment)
		{
			case ToolBar.ALIGNMENT_LEFT: 
				this.#left_aligned_items.push(item);
				break;
			case ToolBar.ALIGNMENT_CENTER:
				this.#center_aligned_items.push(item);
				break;
			case ToolBar.ALIGNMENT_RIGHT: 
				this.#right_aligned_items.push(item);
				break;
		}
	}
	
	display()
	{
		this.#arrange_items();
		for(let tbi_item of this.#left_aligned_items)
		{
			tbi_item.display(this.location);
		}
		for(let tbi_item of this.#center_aligned_items)
		{
			tbi_item.display(this.location);
		}
		for(let tbi_item of this.#right_aligned_items)
		{
			tbi_item.display(this.location);
		}
	}
	
	process_event(event) //: Boolean
	{
		if (event is MouseEvent)
		{
			// TODO: events
			// var mouse_event = MouseEvent(event);
			// var pnt_screen = new Point(mouse_event.stageX, mouse_event.stageY);
			// if (!this.is_inside(pnt_screen)) 
			// {
			// 	return false;
			// }
			
			// var str_event_type = mouse_event.type;
			// var pnt_client = pnt_screen.sub(this.location);
			// var tbi_item = null;
			// for (tbi_item of this.#left_aligned_items) 
			// {
			// 	tbi_item.process_event(str_event_type, pnt_client);
			// }
			// for (tbi_item of this.#center_aligned_items) 
			// {
			// 	tbi_item.process_event(str_event_type, pnt_client);
			// }
			// for (tbi_item of this.#right_aligned_items) 
			// {
			// 	tbi_item.process_event(str_event_type, pnt_client);
			// }
			// return true;
		}
		return false;
	}	
	
	remove_item(item)
	{		
		this.#perform_item_removal(this.#left_aligned_items, item);
		this.#perform_item_removal(this.#center_aligned_items, item);
		this.#perform_item_removal(this.#right_aligned_items, item);
	}	
	
	remove_all_items()
	{
		this.#center_aligned_items = [];
		this.#left_aligned_items = [];
		this.#right_aligned_items = [];
	}

//private methods
	#arrange_aligned_items(alignment, items, margin, item_height)
	{
		let dbl_total_width = margin.width;
		let dbl_bound = 0;
		let tbi_item = null;
		let vector = items.sort(this.#compareItems);
		
		for (let i = 0; i < vector.length; i++)
		{
			tbi_item = vector[i];
			var dbl_width = item_height/tbi_item.extent.height*tbi_item.extent.width;
			tbi_item.location.y = margin.height;
			tbi_item.extent.width = dbl_width;
			tbi_item.extent.height = item_height;
			dbl_total_width += dbl_width + margin.width;
		}
		
		switch (alignment) {
			case ToolBar.ALIGNMENT_RIGHT:
				dbl_bound = extent.width - margin.width;
				break;
			case ToolBar.ALIGNMENT_LEFT:
				dbl_bound = margin.width;
				break;
			case ToolBar.ALIGNMENT_CENTER:
				dbl_bound = extent.width/2 - dbl_total_width/2 + margin.width;
				break;
		}

		for (let n = 0; n < vector.length; n++)
		{
			tbi_item = vector[n];
			
			tbi_item.location.x = dbl_bound - ((alignment == ToolBar.ALIGNMENT_RIGHT) ? tbi_item.extent.width : 0);
			dbl_bound = tbi_item.location.x + ((alignment == ToolBar.ALIGNMENT_RIGHT) ? -margin.width : tbi_item.extent.width + margin.width); 
		}
	}
	
	#arrange_items()
	{
		var sz_margin = new Size(extent.height*ToolBar.#HORIZONTAL_MARGIN, extent.height*ToolBar.#VERTICAL_MARGIN);
		var dbl_height = extent.height*(1 - ToolBar.#VERTICAL_MARGIN*2);
		
		this.#arrange_aligned_items(ToolBar.ALIGNMENT_LEFT, this.#left_aligned_items, sz_margin, dbl_height); 

		this.#arrange_aligned_items(ToolBar.ALIGNMENT_RIGHT, this.#right_aligned_items, sz_margin, dbl_height); 
			
		this.#arrange_aligned_items(ToolBar.ALIGNMENT_CENTER, this.#center_aligned_items, sz_margin, dbl_height); 

	}

	#compare_items(item1, item2) //: Number
	{
		return item2.gravity - item1.gravity;
	}

	#perform_item_removal(list, item)
	{
		for (let i = 0; i < list.length; i++) {
			if (list[i] == item) {
				list.splice(i, 1);
				return;
			}
		}
	}
}


///////////////////////////////////////////////////////////
//  ToolBarEventDispatcher.as
///////////////////////////////////////////////////////////

class ToolBarEventDispatcher extends EventDispatcher 
{
//public consts
	static ON_CLICK() {return "OnClick";}	
	static ON_PAINT() {return "OnPaint";}
	static ON_PRESSED() {return "OnPressed";}
	static ON_RELEASED() {return "OnReleased";}
	static ON_TOGGLE() {return "OnToggle";}

//public methods
	
	fire_on_click(source) {
		//TODO: Event
		//dispatchEvent(new ObjectEvent(ON_CLICK, source));
	}

	fire_on_paint(source) {
		//TODO: Event
		//dispatchEvent(new ObjectEvent(ON_PAINT, source));
	}

	fire_on_pressed(source) {
		//TODO: Event
		//dispatchEvent(new ObjectEvent(ON_PRESSED, source));
	}

	fire_on_released(source) {
		//TODO: Event
		//dispatchEvent(new ObjectEvent(ON_RELEASED, source));
	}

	fire_on_toggle(source) {
		//TODO: Event
		//dispatchEvent(new ObjectEvent(ON_TOGGLE, source));
	}
}

///////////////////////////////////////////////////////////
//  ToolBarToggleButton.as
///////////////////////////////////////////////////////////

class ToolBarToggleButton extends ToolBarItem
{
//property fields
	#checked = false;

//properties
	get checked () //: Boolean
	{
		return this.#checked;
	}
	
	set checked (value)
	{
		this.#checked = value;
		this.on_toggle.fire_on_toggle(this);		
	}

//constructor
	constructor (size, alignment, gravity=0, normal_image=null, pressed_image=null)
	{
		super(size, alignment, gravity, normal_image, pressed_image);
		this.on_toggle = new ToolBarEventDispatcher();
	}

	//public methods

	processEvent(event_type, location)
	{
		super.process_event(event_type, location);
	}
		
//protected methods

	_display_hook() {
		return this.#checked ? 1 : 0;
	}	
	
	_on_click_hook(){
		this.#checked = !this.#checked;
		this.on_toggle.fire_on_toggle(this);
	}
}


///////////////////////////////////////////////////////////
//  IController.as
///////////////////////////////////////////////////////////

class IController //interface
{
	get_controller_type() {return 0};

	process_dispatcher_event(type, param_obj=null) {return false;}

	run() {}
}


///////////////////////////////////////////////////////////
//  GameController.as
///////////////////////////////////////////////////////////

class GameController implements IController //Singleton
{
//private consts
	static #CLOSE_ARRIVAL = 1000;
	static #CLOUD_QUANTITY_RATE = 0.001;
	static #LEAVE_BOUND = -300;
	static #MAX_CLOUD_LENGTH = 10000;
	static #MAX_CLOUD_RATIO = 2;	
	static #MAX_CLOUD_WIDTH = 8000;
	static #MAX_SIMULATION_RATE = 3; //frames per frame
	static #MIN_CLOUD_LENGTH = 2000;
	static #MIN_CLOUD_SPEED = 30;
	static #MIN_CLOUD_WIDTH = 4000;
	static #MIN_FUEL = 0.3; 
	static #MIN_SIMULATION_RATE = 1; //frames per frame
	static #NORMAL_WIND_SPEED = 40;
	static #RUNWAY_CAPTURE_ZONE = 0.75;
	static #RUNWAY_RELEASE_DISTANCE = 1.3; //lengths of the runway
	static #FULL_TANK_POINTS = 1000; 
	static #MAX_ACTIVE_AIRCRAFT_COUNT = 13;
	static #MIN_ACTIVE_AIRCRAFT_COUNT = 3;
	static #MIN_EMIT_INTERVAL = 128; //frames
	static #SIMULSTION_ACCELERATION = 3; //times
	static #WAYPOINT_CREATION_TIMEOUT = 50; //milliseconds between waypoint creation

//property fields
	#landings_done = 0;
	#landings_to_do = 0;
	#simulation_rate = 1;	

//other private fields
	#airport = null;
	static #controller_instance = null;
	#previous_simulation_rate = 0;
	#waypoint_created: = null;
	#is_creating_path = false;
	#is_loading_level = false;
	#is_new_path = false;
	#emit_frames_interval = 0; //frames	
    #selected_aircraft = null;
    #selected_airfield = null;
	#sound_channel = null;
	#url_loader = null;	

//properties

	get landings_done() //: int
    {
    	return this.#landings_done;
    }

	get landings_to_do() //: int
    {
    	return this.#landings_to_do;
    }
	
	get shift_progress() //: int
    {
    	return int(this.#landings_done * 100 / this.#landings_to_do);
    }

    get simulation_rate() //: Number
    {
    	return this.#simulation_rate;
    }

//methods
	//constructor 
	//private constructors not supported by actionscript
	//use get_instance instead!
   	constructor(airport)
	{
		this.airport = airport;
		//TODO: events
		// this.airport.on_level_loaded.addEventListener(CustomDispatcher.ON_LEVEL_LOADED, airport_on_level_loaded);
		// this.airport.on_gate_loaded.addEventListener(CustomDispatcher.ON_GATE_LOADED, airport_on_gate_loaded);
		//FrameBuilder.before_rescale.add_event_listener(CustomDispatcher.BEFORE_RESCALE, frame_builder_before_rescale);
		//HintPanelView.on_hiding.addEventListener(CustomDispatcher.ON_HIDING, hint_panel_view_on_hiding);
		//HintPanelView.on_shown.addEventListener(CustomDispatcher.ON_SHOWN, hint_panel_view_on_shown);
	}

	static get_instance(airport=null) //: GameController
	{
		if (!GameController.#controller_instance)
		{
			GameController.#controller_instance = new GameController(airport);
		}
		return GameController.#controller_instance;
	}

	//public methods
	fix_airport_rect(hor_zoom, vert_zoom)
    {
		this.airport.fix_airport_rect(hor_zoom, vert_zoom);
	}

	get_controller_type() //: int 
	{
		return Controllers.GAME_CONTROLLER;
	}

	process_dispatcher_event(event_type, param_obj=null) //: Boolean
	{
		switch (event_type)
		{
			case OutcomingDispatcherEventTypes.FAST_SIMULATION:
				if (param_obj.FastMode && (this.#simulation_rate == 1 
					|| this.#simulation_rate == 0 && this.#previous_simulation_rate == 1)) 
				{
					this.#accelerate();
				}
				else if (!param_obj.FastMode && (this.#simulation_rate > 1 
					|| this.#simulation_rate == 0 && this.#previous_simulation_rate > 1)) 
				{
					this.#decelerate();
				}
				return true;
				
			case OutcomingDispatcherEventTypes.NEXT_LEVEL:
				this.#next_level();
				return true;	

			case OutcomingDispatcherEventTypes.PATH_FINISH:
				return this.#finish_path(param_obj.Position);
				
			case OutcomingDispatcherEventTypes.PATH_CONTINUE:
				return this.#continue_path(param_obj.Position);
				
			case OutcomingDispatcherEventTypes.PAUSE_SIMULATION:
				if (param_obj.PauseMode && (this.#simulation_rate > 0)) {
					this.#pause();
				}
				else if (!param_obj.PauseMode && (this.#simulation_rate == 0)) {
					this.#resume();
				}			
				return true;
				
			case OutcomingDispatcherEventTypes.START_LEVEL:
				this.#start_level();
				return true;	

			case OutcomingDispatcherEventTypes.OBJECT_ACTIVATE:
				this.#select(param_obj.Position, true);
				return true;
				
			case OutcomingDispatcherEventTypes.OBJECT_INFO:
				return this.#trace_object_info();
				
			case OutcomingDispatcherEventTypes.OBJECT_SELECT:
				this.#select(param_obj.Position, false);
				return true;

			case OutcomingDispatcherEventTypes.SHOW_HINTS:
				if (HintPanelView.IsShown)
					return HintPanelView.hide(true);
				else
					return HintPanelView.show(true);

			case OutcomingDispatcherEventTypes.PLAY_LEVEL:
				this.#play_level();
				return true;	
				
			case OutcomingDispatcherEventTypes.DISPLAY_MODE_CHANGED:
				if (ControlDispatcher.CurrentDisplayMode != DisplayMode.Play) {
					this.#stop_playing_melody();
				}
				return true;
		}
		return false;
	}

	run()
    {
		let n_frames: int = int(this.#simulation_rate*2);
		
		for (let j = 0; j < n_frames; j++)
		{
			if (ControlDispatcher.current_display_mode == DisplayMode.PLAY)
			{
				this.#detect_collisions();
				this.#detect_collisions();
			}
			
			if (ControlDispatcher.current_display_mode != DisplayMode.PLAY) return;
				
			this.airport.update_wind();
			
			for (let airfield of this.airport.airfields)
			{
				airfield.update_wind(this.airport.current_wind.direction);
			}
			
			this.#control_aircraft_quantity(this.#move_aircrafts());
			this.#control_clouds();
		}
    }

//private methods
	#accelerate()
	{
		if (this.#simulation_rate == 0) {
			this.#previous_simulation_rate = Math.min(this.#previous_simulation_rate*GameController.#SIMULSTION_ACCELERATION, GameController.#MAX_SIMULATION_RATE);
		}
		else {
			this.#simulation_rate = Math.min(this.#simulation_rate*GameController.#SIMULSTION_ACCELERATION, GameController.#MAX_SIMULATION_RATE);
		}
	}

	#add_waypoint(aircraft, position)
	{
		if (this.#is_new_path)
		{			
			aircraft.path.remove_all();
			aircraft.target_airfield = null;
			this.#is_new_path =  false;
		}
		
		//проверяем на принадлежность ВВП
		for each (let airfield of this.airport.airfields)
		{
			if (this.#check_airfield_capture(airfield, position, aircraft)) return;
		}
			
		aircraft.path.append(position);
		this.#waypoint_created = new Date(); 
		
		//отрыв пути от ВПП
		if (aircraft.target_airfield)
		{
			let obj_dist2 = {Distance: 0};
			Angle.direction(airfield.location, position, obj_dist2);
			if (obj_dist2.Distance > aircraft.target_airfield.length * GameController.#RUNWAY_RELEASE_DISTANCE)
			{
				aircraft.target_airfield = null;					
				this.#deselect(false);								
			}
		}
	}
	
	#check_airfield_capture(airfield, position, aircraft) //: Boolean
	{
		if (Instruments.xor(aircraft.type == AircraftType.copter, airfield is Runway) && airfield.in_area(position))
		{
			let to_capture = false;
			if (airfield.is_runway)
			{
				var obj_dist = {Distance: 0};
				Angle.direction(airfield.location, position, obj_dist);
				to_capture = (obj_dist.Distance / (airfield.length / 2) > GameController.#RUNWAY_CAPTURE_ZONE);
			}
			
			//захват ВПП
			if (!airfield.is_runway || to_capture)
			{
				aircraft.target_airfield = airfield;
				this.#deselect(false);					
				this.#select_airfield(airfield);
				return true;
			}
		}
		return false;
	}
	
	#continue_path(position) //: Boolean
    {
		if (this.#is_creating_path)
		{
			let dt_current_time = new Date();

			if (dt_current_time.valueOf() - this.#waypoint_created.valueOf() > GameController.#WAYPOINT_CREATION_TIMEOUT)
			{
				this.#add_waypoint(this.#selected_aircraft, position);
			}
			return true;
		}
		
		return false;
	}
	
	#control_aircraft_quantity(aircraft_quantity)
	{
		this.#emit_frames_interval += 1;
		if (this.#landings_done + aircraft_quantity < this.#landings_to_do)
		{
			if (aircraft_quantity < GameController.#MIN_ACTIVE_AIRCRAFT_COUNT)
			{
				this.#emit_frames_interval = GameController.#MIN_EMIT_INTERVAL;
				this.#emit_aircrafts(false);
			}
			else
			{
				if (Math.random() < this.airport.TrafficIntensity && aircraft_quantity < GameController.#MAX_ACTIVE_AIRCRAFT_COUNT)
					this.#emit_aircrafts(true); 
			}
		}
	}

	#control_clouds()
	{
		if (this.airport.current_wind.speed > GameController.#MIN_CLOUD_SPEED && Math.random() < this.airport.cloud_probability)
		{
			this.#emit_cloud();
		}
		
		for (let i; i < this.airport.clouds.length; i++)
		{
			var cloud = this.airport.Clouds[i];
			cloud.move(this.airport.current_wind);
			if (this.#is_cloud_left(cloud))
			{
				this.airport.clouds.splice(i, 1);
			}
		}
	}		

	#create_aircraft(aircraft_type, location, course, airport_rect, aircraft_state, fuel_residue, gate=null) //: Aircraft
	{
		if (aircraft_type == AircraftType.copter)
<<<<<<<<<<<<<<<<======== Current place - level 6 ========
			return new Copter(aircraft_type, location, course, airport_rect, aircraft_state, fuel_residue, gate);
		else
			return new Plane(aircraft_type, location, course, airport_rect, aircraft_state, fuel_residue, gate);
	}

	#decelerate()
	{
		if (this.#simulation_rate == 0) {
			this.#previous_simulation_rate = Math.max(this.#simulation_rate/GameController.#SIMULSTION_ACCELERATION, GameController.#MIN_SIMULATION_RATE);
		}
		else {
			this.#simulation_rate = Math.max(this.#simulation_rate/GameController.#SIMULSTION_ACCELERATION, GameController.#MIN_SIMULATION_RATE);
		}
	}
	
	#deselect(to_deselect_aircraft, to_deselect_airfield=true)
	{
		if (to_deselect_aircraft)
		{
			if (this.#selected_aircraft != null) { this.#selected_aircraft.Selected = false; this.#selected_aircraft = null; }
		}
		
		if(to_deselect_airfield)
		{
			if (this.#selected_airfield != null) { this.#selected_airfield.Selected = false; this.#selected_airfield = null; }
		}
	}

	#detect_close_arrivals(location)
	{
		for each(var aircraft: Aircraft in this.airport.Aircrafts)
		{
			if (Math.abs(aircraft.location.x - location.x) < GameController.#CLOSE_ARRIVAL 
				|| Math.abs(aircraft.location.y - location.y) < GameController.#CLOSE_ARRIVAL)
			{
				return true;
			}
		}
		return false;
	}
	
	#detect_collisions()
	{
		for (var i: int = 0; i < this.airport.Aircrafts.length; i++)
		{
			for (var j: int = i + 1; j < this.airport.Aircrafts.length; j++)
			{
				if (this.airport.Aircrafts[i].check_collision(this.airport.Aircrafts[j]))
					ControlDispatcher.CurrentDisplayMode = DisplayMode.CrashPause;
			}
		}		
	}
	
	#emit_aircrafts(is_arriving)
	{
		if (this.#emit_frames_interval < GameController.#MIN_EMIT_INTERVAL || this.#landings_done == this.#landings_to_do) return;
		
		var mo_place: SelectableObject = null;
		var i: int = 0;
		do 
		{
			mo_place = this.#get_random_boundary_position(new Angle(Math.random()*360 - 180, Angle.DEGREE));		
		}
		while (this.#detect_close_arrivals(mo_place.location) && ++i < 20);		
		if (!mo_place) return;

		var dbl_wind_koef = 1 + (this.airport.CurrentWind.maximal_speed - GameController.#NORMAL_WIND_SPEED) 
			/ (this.airport.CurrentWind.DBL_MAX_WIND_SPEED - GameController.#NORMAL_WIND_SPEED);
		if (dbl_wind_koef < 1) dbl_wind_koef = 1;
		var aircraft: Aircraft = this.#create_aircraft(this.#pick_aircraft_type(), mo_place.location, mo_place.course, this.airport, 
			is_arriving ? AircraftState.ARRIVING : AircraftState.UNDIRECTED, 
			Math.random()*(1 - GameController.#MIN_FUEL*dbl_wind_koef) + GameController.#MIN_FUEL*dbl_wind_koef);
		
		
		aircraft.OnLanded.addEventListener(CustomDispatcher.ON_LANDED, this.#aircraft_on_landed);

		this.airport.Aircrafts.push(aircraft);
				
		this.#emit_frames_interval = 0;
	}

	#emit_cloud(on_boundary_only=true)
	{
		var dbl_len = Math.max(Math.random()*GameController.#MAX_CLOUD_LENGTH, GameController.#MIN_CLOUD_LENGTH);
		var dbl_width = Math.max(Math.random()*GameController.#MAX_CLOUD_WIDTH, GameController.#MIN_CLOUD_WIDTH);
		var n_density: int = int(Math.floor(Math.random()*Cloud.MAX_DENSITY*this.airport.CloudProbability/Cloud.AVG_PROBABILITY)) + 1;
		var dbl_ratio =  dbl_len / dbl_width;
		if (dbl_ratio < 1)
		{
			var dbl_swap = dbl_len;
			dbl_len = dbl_width;
			dbl_width = dbl_swap;
			dbl_ratio = 1 / dbl_ratio;
		}
		if (dbl_ratio > GameController.#MAX_CLOUD_RATIO) dbl_width = dbl_len / GameController.#MAX_CLOUD_RATIO;

		var pnt_location: Point;
		if (on_boundary_only)
		{
			pnt_location = this.#get_random_boundary_position(this.airport.CurrentWind.direction).location;
		}
		else
		{
			pnt_location = new Point(this.airport.location.x + this.airport.extent.width*Math.random(), this.airport.location.y + this.airport.extent.height*Math.random());
		}
		
		this.airport.Clouds.push(new Cloud(pnt_location, new Size(dbl_width, dbl_len), 
			new Angle(Math.random()*360 - 180, Angle.DEGREE), n_density));
	}
	
	#finish_path(position) //: Boolean
    {			
		if (this.#is_creating_path)
		{
			this.#add_waypoint(this.#selected_aircraft, position);
			this.#is_creating_path = false;
			return true;
		}
		
		return false;
	}
	
	#get_cloud_density(aircraft) //: int
	{
		var n_clouds: int = 0;
		for each (var cloud: Cloud in this.airport.Clouds)
		{
			var pnt_diff: Point = cloud.location.sub(aircraft.location);
			if ((Math.max(Math.abs(pnt_diff.x), Math.abs(pnt_diff.y)) <= Math.max(cloud.extent.width/2, cloud.extent.height/2))
				&& cloud.in_area(aircraft.location))
			{
				n_clouds += cloud.Density;
			}
		}
		return n_clouds;
	}
		
	#get_random_boundary_position(course) //: SelectableObject
	{		
		var dbl_angle = course.Degree;
		var dbl_x_var = (dbl_angle > 45 && dbl_angle <= 135) ? 0 : ((dbl_angle < -45 && dbl_angle > -135) ? 1 : Math.random());
		var dbl_y_var = (dbl_angle > 45 && dbl_angle <= 135 || dbl_angle < -45 && dbl_angle > -135) ? Math.random()
			: ((dbl_angle >= -45 && dbl_angle <= 45) ? 1 : 0);
		
		var x = this.airport.location.x + this.airport.extent.width*dbl_x_var;
		var y = this.airport.location.y + this.airport.extent.height*dbl_y_var; 
		return new SelectableObject(new Point(x, y), new Size(0, 0), course);		
	}
	
	#init_level()
	{
		this.airport.Airfields.length = 0;
		this.airport.Aircrafts.length = 0;
		this.airport.Aprons.length = 0;
		this.airport.Gates.length = 0;
		this.airport.Clouds.length = 0;
		this.#simulation_rate = 1;
		this.#landings_done = 0;
	}

	#is_cloud_left(cloud) //: Boolean
	{
		//если центр облака ушел
		if (this.airport.isInside(cloud.location)) return false;

		//смотрим ушли ли угловые точки
		var apnt: Vector.<Point> = cloud.CornerPoints;
		for (var i = 0; i < apnt.length; i++)
		{
			if (this.airport.isInside(apnt[i]))
			{
				return false;
			}				
		}
		return true;
	}	
		
	#load_level()
    {
		var strFile: String = "levels/Level" + GameProgress.level.to_string() + ".xml";
		this.#url_loader = new URLLoader();
		var urlr_file: URLRequest = new URLRequest(strFile);
		try {
			this.#url_loader.addEventListener(Event.COMPLETE, this.#url_loader_on_complete);			
			this.#url_loader.load(urlr_file);
		} 
		catch (error:Error) 
		{
			console.log("  Unable to load file " + strFile);
		}		
    }

	#load_level_cont()
	{
		var xml_doc: XML = new XML(this.#url_loader.data);
		this.#url_loader.close();

		var xml_airport: XML = xml_doc.airport[0];
		if (!xml_airport)
		{
			console.log("Failed to load level: airport tag not found.");
			return;
		}
		
		this.#landings_to_do = xml_doc.@targetLandings;		
		HintPanelView.Hints.length = 0;
		HintPanelView.ClipIds.length = 0;
		for each (var xml_hint: XML in xml_doc.hints.hint)
		{
			HintPanelView.Hints.push(xml_hint);
			HintPanelView.ClipIds.push(xml_hint.@clipId);
		}
		this.airport.load_level("levels/Level" + GameProgress.level.to_string() + ".xml");		
	}

	#move_aircrafts() //: int
    {
		var n_aircrafts_count: int = 0;
		for (var i: int = 0; i < this.airport.Aircrafts.length; i++)
		{
			var aircraft: Aircraft = this.airport.Aircrafts[i];
			//проверяем попадание в облако
			aircraft.move(this.airport.CurrentWind, this.#get_cloud_density(aircraft));
			
			if (aircraft.state == AircraftState.TAKING_OFF
				&& (
					aircraft.location.x - this.airport.location.x < GameController.#LEAVE_BOUND 
					|| this.airport.location.x + this.airport.extent.width - aircraft.location.x < GameController.#LEAVE_BOUND 
					|| aircraft.location.y - this.airport.location.y < GameController.#LEAVE_BOUND 
					|| this.airport.location.y + this.airport.extent.height - aircraft.location.y < GameController.#LEAVE_BOUND
				)
			)
			{
				this.airport.Aircrafts.splice(i, 1);
			}
			else
				if (aircraft.state.is_coming || aircraft.state == AircraftState.TAXIING_TO_GATE || aircraft.state == AircraftState.ARRIVING)
					n_aircrafts_count++;
		}
		return n_aircrafts_count;
	}	

	#next_level() //: void
    {
		GameProgress.next_level();
		this.#init_level();		
	}

	#pause() //: void
	{
		this.#previous_simulation_rate = this.#simulation_rate;
		this.#simulation_rate = 0;
	}

	#pick_aircraft_type(can_pick_copter=true) //: AircraftType
	{
		var dbl_random = Math.random();
		var dbl_copter = this.airport.CopterRate;
		var dbl_prop = this.airport.PropRate;
		
		if (can_pick_copter && dbl_random < dbl_copter)
			return AircraftType.copter;		
		if (dbl_random < dbl_copter + dbl_prop)
			return AircraftType.propeller;
		else if (dbl_random < dbl_copter + dbl_prop + this.airport.LinerRate)
			return AircraftType.liner;
		else
			return AircraftType.supersonic;
	}

	#play_level()
	{
		if (this.#is_loading_level) return;
		this.#is_loading_level = true;
		
		this.#init_level();
		this.#load_level();
	}	

	#prepare_game_start()
    {
		ControlDispatcher.CurrentDisplayMode = DisplayMode.Play;
				
		for(var i: int = 0; i < this.airport.CloudProbability / GameController.#CLOUD_QUANTITY_RATE; i++)
			this.#emit_cloud(false);
		
		HintPanelView.show();
		StarView.clear();
		this.#start_playing_melody(GameProgress.Level);
		
		this.#is_loading_level = false;
	}

	#resume()
	{
		this.#simulation_rate = this.#previous_simulation_rate;
	}

    #select(point, is_double_clicked) 
    {
		for each(var aircraft: Aircraft in this.airport.Aircrafts)
		{
			if (!aircraft.in_area(point) || aircraft.state == AircraftState.TAKING_OFF) continue;

			if (!is_double_clicked && aircraft.state.is_coming)
			{
				this.#is_new_path = true;
				this.#is_creating_path = true;
				this.#waypoint_created = new Date();
			}
			
			this.#select_aircraft(aircraft);
			
			if (is_double_clicked)
				aircraft.depart();
			
			return;
		}
		
		if (this.#selected_aircraft == null) return;
		
		for each (var airfield: IAirfield in this.airport.Airfields)
		{
			if (!airfield.in_area(point)) continue;
			
			this.#select_airfield(airfield);
			return;
		}		
    }

	#select_aircraft(aircraft)
	{
		this.#deselect(true, true);
		
		aircraft.Selected = true;					
		this.#selected_aircraft = aircraft;
		
		if (this.#selected_aircraft.target_airfield != null && aircraft.state == AircraftState.DIRECTED || aircraft.state == AircraftState.LANDING)
			this.#select_airfield(this.#selected_aircraft.target_airfield);
	}

	#select_airfield(airfield)
	{
		//Если самолет на земле, то не направляем его на ВВП если: самолет уже покинул гейт или гейт не относится к этой полосе		 
		if (!this.#selected_aircraft.state.is_coming && (!this.#selected_aircraft.occupied_gate || !this.#selected_aircraft.occupied_gate.isHostedBy(airfield))) return;

		this.#deselect(false, true);		
							
		airfield.Selected = true;					
		this.#selected_airfield = airfield;
		
		this.#selected_aircraft.target_airfield = airfield;		
	}

	#start_level()
	{
		this.#init_level();
		ControlDispatcher.CurrentDisplayMode = DisplayMode.LevelStartBanner;
	}
	
	#start_playing_melody(level_number)
	{
		var transform: SoundTransform = new SoundTransform(0.3, 0);
		var n_melody: int = level_number % 6;
		var class_sound: Class = getDefinitionByName("Melody"+n_melody.to_string()) as Class;
		var snd_melody: Sound = new class_sound();
		this.#sound_channel = snd_melody.play(10000, 0);
		this.#sound_channel.soundTransform = transform;
	}
			
	#stop_playing_melody()
	{
		if(this.#sound_channel) this.#sound_channel.stop();
	}			
			
	#trace_object_info() //: Boolean
	{
		var is_traced = false;
		if (this.#selected_aircraft)
		{
			console.log(this.#selected_aircraft);
			is_traced = true;
		}
		if (this.#selected_airfield)
		{
			console.log(this.#selected_airfield);
			is_traced = true;			
		}
		
		return is_traced;
	}	
	
//event handlers
	#airport_on_gate_loaded(event)
	{
		var gate: Gate = Gate(ObjectEvent(event).SourceObject)
		if (!gate.Free)
		{
			var aircraft: Aircraft = this.#create_aircraft((gate is Helipad) ? AircraftType.copter : this.#pick_aircraft_type(false),
				gate.location, new Angle(), this.airport, AircraftState.PREPARING_TO_TAKEOFF, Math.random(), gate);
			
			this.airport.Aircrafts.push(aircraft);
		}
	}	
	
	#airport_on_level_loaded(event) 
	{
		this.#prepare_game_start();
	}

	#frame_builder_before_rescale(event)
	{
		this.fix_airport_rect(this.airport.extent.width / FrameBuilder.GameZoneRect.extent.width, this.airport.extent.height / FrameBuilder.GameZoneRect.extent.height);	
	}

	#aircraft_on_landed(event)
	{
		this.#landings_done += 1;
		var aircraft: Aircraft  = (Aircraft)(event.SourceObject); 
		GameProgress.addPoints(int(aircraft.fuel*GameController.#FULL_TANK_POINTS));
		StarView.addStar(FrameBuilder.convertToScreenPoint(aircraft.location));
	}

	#hint_panel_view_on_hiding(event)
	{
		Core.resume();
	}
	
	#hint_panel_view_on_shown(event)
	{
		Core.suspend();
	}	

	#url_loader_on_complete(event)
	{
		this.#load_level_cont();
	}	
}

///////////////////////////////////////////////////////////
//  InfoPanelView.as
///////////////////////////////////////////////////////////

class InfoPanelView //static
{
	//зависимые константы - порядок важен
	static #WIND_ARROW_HEIGHT = InfoPanelView.#WIND_INDICATOR_LENGTH*0.6;  
	static #WIND_ARROW_WIDTH = DBL_WIND_ARROW_HEIGHT
	static #WIND_INDICATOR_LENGTH = 20;
	static #WIND_INDICATOR_SIZE = new Size(InfoPanelView.#WIND_INDICATOR_LENGTH, InfoPanelView.#WIND_INDICATOR_LENGTH);
	
	//event handling 
	static #TO_HANDLE_CLICK = 1;
	static #TO_HANDLE_PAINT = 2;
	static #TO_HANDLE_TOGGLE = 4;

	//toolbar item indices
	static #BUTTON_INDEX_LEVEL_NUMBER = 0;
	static #BUTTON_INDEX_WIND_INDICATOR = 1;
	static #BUTTON_INDEX_PROGRESS = 2;
	static #BUTTON_INDEX_POINTS = 3;
	static #BUTTON_INDEX_FAST_PLAY = 4;
	static #BUTTON_INDEX_PAUSE_PLAY = 5;
	static #BUTTON_INDEX_RESTART = 6;
	static #BUTTON_INDEX_HINT = 7;
	static #BUTTON_INDEX_BACK_TO_MENU = 8;
	static #BUTTON_INDEX_INFO = 9;		
	
	//in order of depedance
	static #play_only = DisplayMode.PLAY.value;
	static #DISPLAY_MODES = [
		InfoPanelView.#play_only, 
		InfoPanelView.#play_only, 
		InfoPanelView.#play_only, 
		InfoPanelView.#play_only, 
		InfoPanelView.#play_only,
		InfoPanelView.#play_only, 
		InfoPanelView.#play_only, 
		InfoPanelView.#play_only, 
		DisplayMode.PLAY.value | DisplayMode.LEVEL_MENU.value, 
		DisplayMode.BOX_MENU.value);
	static #TOOLBAR_ITEMS_NUMBER = 10;
	static #ITEMS = [];
	static #BUTTON_SIZE = new Size(20, 20);
	static #LEVEL_NUMBER_LABEL_SIZE = new Size(70, 20);
	static #POINTS_LABEL_SIZE = new Size(120, 20);
	static #PROGRESS_INDICATOR_SIZE = new Size(60, 20);
	static #SIZES = [
		InfoPanelView.#LEVEL_NUMBER_LABEL_SIZE, 
		InfoPanelView.#WIND_INDICATOR_SIZE, 
		InfoPanelView.#PROGRESS_INDICATOR_SIZE,
		InfoPanelView.#POINTS_LABEL_SIZE, 
		InfoPanelView.#BUTTON_SIZE, 
		InfoPanelView.#BUTTON_SIZE, 
		InfoPanelView.#BUTTON_SIZE, 
		InfoPanelView.#BUTTON_SIZE, 
		InfoPanelView.#BUTTON_SIZE, 
		InfoPanelView.#BUTTON_SIZE];
	
	//other toolbar items' properties
	static #GRAVITY_VALUES = [Number.MAX_SAFE_INTEGER, 
		0, 
		0, 
		Number.MIN_SAFE_INTEGER, 
		Number.MAX_SAFE_INTEGER, 
		Number.MAX_SAFE_INTEGER - 1, 
		0, 
		Number.MIN_SAFE_INTEGER + 1, 
		Number.MIN_SAFE_INTEGER, 
		0];
	static #HANDLED_EVENTS = [
		InfoPanelView.#TO_HANDLE_PAINT, 
		InfoPanelView.#TO_HANDLE_PAINT, 
		InfoPanelView.#TO_HANDLE_PAINT, 
		InfoPanelView.#TO_HANDLE_PAINT, 
		InfoPanelView.#TO_HANDLE_TOGGLE, 
		InfoPanelView.#TO_HANDLE_TOGGLE, 
		InfoPanelView.#TO_HANDLE_CLICK, 
		InfoPanelView.#TO_HANDLE_CLICK, 
		InfoPanelView.#TO_HANDLE_CLICK, 
		InfoPanelView.#TO_HANDLE_CLICK];
	static #ITEMS_ALIGNMENT = [
		ToolBar.ALIGNMENT_LEFT, 
		ToolBar.ALIGNMENT_CENTER,
		ToolBar.ALIGNMENT_LEFT, 
		ToolBar.ALIGNMENT_LEFT, 
		ToolBar.ALIGNMENT_RIGHT, 
		ToolBar.ALIGNMENT_RIGHT, 
		ToolBar.ALIGNMENT_RIGHT, 
		ToolBar.ALIGNMENT_RIGHT, 
		ToolBar.ALIGNMENT_RIGHT, 
		ToolBar.ALIGNMENT_RIGHT];
	//TODO: Image creation
	static #NORMAL_IMAGES = [
		null, 
		null, 
		null, 
		null, 
		null, //new ButtonNormalFastImage(), 
		null, //new ButtonNormalPauseImage(), 
		null, //new ButtonNormalRestartLevelImage(), 
		null, //new ButtonNormalHintImage(), 
		null, //new ButtonNormalBackToMenuImage(), 
		null, //new ButtonNormalInfoImage()
	];
	static #PRESSED_IMAGES = [
		null, 
		null, 
		null, 
		null, 
		null, //new ButtonPressedFastImage(),
		null, //new ButtonPressedPauseImage(), 
		null, //new ButtonPressedRestartLevelImage(), 
		null, //new ButtonPressedHintImage(), 
		null, //new ButtonPressedBackToMenuImage(),
		null, //new ButtonPressedInfoImage()
	];
	
	//остальные константы
	static #CY_OP_PADDING = 2.0; //вертикальные поля 
	static #TOOLBAR_HORIZONTAL_MARGIN = 0.01; //of toolbar width
	static #TOOLBAR_VERTICAL_MARGIN = 0.05; //of toolbar height 

	static #Y_TITLE_LEVEL_NUMBER = 0;
	static #Y_TITLE_POINTS_NUMBER = 0;

	//other fields
	static #airport = null;
	static #last_display_mode = null;	
	static #tool_bar = null;

//public methods
	static display(airport) 
	{
		InfoPanelView.#airport = airport;
			
		//панель
		//TODO: creating and displaying image
		// ScreenManager.display_image(new InfoPanelImage(), 
		// 	FrameBuilder.info_panel_rect, new Angle());
		
		InfoPanelView.#display_tool_bar();
	}	

	static process_event(event) //: Boolean
	{
		if (event.type == Core.DISPLAY_MODE_CHANGE)
		{
			InfoPanelView.#uncheck_button(InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_FAST_PLAY]);
			InfoPanelView.#uncheck_button(InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_PAUSE_PLAY]);
		}
		
		if (!InfoPanelView.#tool_bar) return false;
		//TODO: Event processing
		return null; //InfoPanelView.#tool_bar.process_event(event);
	}

//private methods
	static #add_buttons()
	{
		for (let i = 0; i < InfoPanelView.#TOOLBAR_ITEMS_NUMBER; i++)
		{
			if ((ControlDispatcher.current_display_mode.id & InfoPanelView.#DISPLAY_MODES[i]) == 0) continue;
			InfoPanelView.#ITEMS[i] = InfoPanelView.#add_tool_bar_item(
				InfoPanelView.#ITEMS[i], 
				InfoPanelView.#SIZES[i], 
				InfoPanelView.#HANDLED_EVENTS[i], 
				InfoPanelView.#ITEMS_ALIGNMENT[i], 
				InfoPanelView.#GRAVITY_VALUES[i], 
				InfoPanelView.#NORMAL_IMAGES[i], 
				InfoPanelView.#PRESSED_IMAGES[i]);
		}
	
		if (HintPanelView.hints.length == 0) InfoPanelView.#tool_bar.remove_item(InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_HINT]);
	}

	static #add_tool_bar_item(tool_bar_item, size, handled_events=InfoPanelView.#TO_HANDLE_CLICK, alignment=0, 
		gravity=0, normal_image=null, pressed_image=null) //: ToolBarItem
	{
		if (!tool_bar_item) 
		{
			if ((handled_events & InfoPanelView.#TO_HANDLE_TOGGLE) != 0) 
			{
				var tbtb = null;
				tbtb = new ToolBarToggleButton(size.clone(), alignment, gravity, normal_image, pressed_image);
				//TODO: event
				//tbtb.on_toggle.addEventListener(ToolBarEventDispatcher.ON_TOGGLE, InfoPanelView.#tool_bar_toggle_button_on_toggle);
				tool_bar_item = tbtb;
			}
			else 
			{
				tool_bar_item = new ToolBarItem(size.clone(), alignment, gravity, normal_image, pressed_image);
			}
			
			if ((handled_events & InfoPanelView.#TO_HANDLE_CLICK) != 0) 
			{
				//TODO: event
				//tool_bar_item.on_click.addEventListener(ToolBarEventDispatcher.ON_CLICK, InfoPanelView.#tool_bar_item_on_click);					
			}

			if ((handled_events & InfoPanelView.#TO_HANDLE_PAINT) != 0) {
				//TODO: event
				//tool_bar_item.on_paint.addEventListener(ToolBarEventDispatcher.ON_PAINT, InfoPanelView.#tool_bar_item_on_paint);
			}
		}
		InfoPanelView.#tool_bar.add_item(tool_bar_item);
		return tool_bar_item;
	}
	
	static #control_buttons_state()
	{
		if (ControlDispatcher.current_display_mode != DisplayMode.PLAY) return;

		InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_HINT].pressed = HintPanelView.is_shown;
	}

	static #create_tool_bar()
	{	
		let rect_info_panel = FrameBuilder.info_panel_rect;
		var pnt_margins: Point = new Point(rect_info_panel.extent.width*InfoPanelView.#TOOLBAR_HORIZONTAL_MARGIN, 
			rect_info_panel.extent.height*InfoPanelView.#TOOLBAR_VERTICAL_MARGIN);
		var sz_tool_bar = new Size(rect_info_panel.extent.width - pnt_margins.x*2,
			rect_info_panel.extent.height - pnt_margins.y*2);
		
		InfoPanelView.#tool_bar = new ToolBar(
			rect_info_panel.location.add(pnt_margins), 
			sz_tool_bar
		);
	}		

	static #display_level_number(display_rect)
	{
		display_rect.location.y = display_rect.location.y + FrameBuilder.adapt_to_frame(InfoPanelView.#Y_TITLE_LEVEL_NUMBER);
		display_rect.extent = new Size(-1, -1);
		ScreenManager.display_text("Level " + GameProgress.level.to_string(), display_rect,
			FrameBuilder.adapt_to_frame(ScreenManager.FONT_SIZE_SMALL), Colors.BROWN);
	}	

	static #display_points(display_rect)
	{
		display_rect.location.y = display_rect.location.y + FrameBuilder.adapt_to_frame(InfoPanelView.#Y_TITLE_POINTS_NUMBER);
		display_rect.extent = new Size(-1, -1);
		ScreenManager.display_text("Points: " + GameProgress.points.to_string(), display_rect,
			FrameBuilder.adapt_to_frame(ScreenManager.FONT_SIZE_SMALL), Colors.BROWN);	
	}

	static #display_progress_widget(display_rect)
	{
		//звездочки
		//TODO: sprite creation
		//var sp_progress = new ProgressImage();
//		var cy_padding = FrameBuilder.adapt_to_frame(InfoPanelView.#CY_OP_PADDING);
		display_rect.location.y = display_rect.location.y /*+ cy_padding*/ + display_rect.extent.height / 2;
//		display_rect.extent.height = display_rect.extent.height - cy_padding*2;
		let dbl_zoom = display_rect.extent.height / sp_progress.height;
		display_rect.extent.width = sp_progress.width * dbl_zoom;

		//заполнитель
		var rect_filler = display_rect.clone();
		//TODO: sprite creation
		// var sp_filler = new ProgressFillerImage();
<<<<<<<<<<<<<<<<======== Current place - level 5 ========
		var gc: GameController = GameController.get_instance();
		rect_filler.extent.width = sp_filler.width * dbl_zoom * gc.landings_done / gc.landings_to_do;

		ScreenManager.displayImage(sp_filler, rect_filler);
		ScreenManager.displayImage(sp_progress, display_rect);
	}

	static #display_tool_bar()
	{
		var dm_current_mode: DisplayMode = ControlDispatcher.CurrentDisplayMode;
		if (dm_current_mode != InfoPanelView.#last_display_mode) {
			InfoPanelView.#last_display_mode = dm_current_mode;
			if (!InfoPanelView.#tool_bar) InfoPanelView.#create_tool_bar();
			InfoPanelView.#tool_bar.remove_all_items();

			if (ControlDispatcher.CurrentDisplayMode.AirportShown && ControlDispatcher.CurrentDisplayMode != DisplayMode.Edit
				|| ControlDispatcher.CurrentDisplayMode == DisplayMode.LevelMenu
				|| ControlDispatcher.CurrentDisplayMode == DisplayMode.BoxMenu)
			{
				InfoPanelView.#add_buttons();
			}
		}
		InfoPanelView.#control_buttons_state();
		InfoPanelView.#tool_bar.display();
	}	

	static #display_wind_indicator_widget(display_rect: Rect)
	{
		var sp_frame: Sprite = new WindIndicatorFrameImage();
		var sp_arrow: Sprite = new WindIndicatorArrowImage();
		var sp_filler: Sprite = new WindIndicatorFillerImage();

		display_rect.location.x = display_rect.location.x + display_rect.extent.width/2;
		display_rect.location.y = display_rect.location.y + display_rect.extent.height/2;
		//displaying frame
		//var dbl_wind_indi_size = FrameBuilder.adaptToFrame(InfoPanelView.#WIND_INDICATOR_LENGTH);
		var dbl_zoom = display_rect.extent.height / InfoPanelView.#WIND_INDICATOR_LENGTH;
		
		ScreenManager.displayImage(sp_frame, display_rect);

		//dispalying wind arrow
		var cy_arrow = DBL_WIND_ARROW_HEIGHT * dbl_zoom;

		display_rect.extent.height = cy_arrow; //* ratio
		display_rect.extent.width = InfoPanelView.#WIND_ARROW_WIDTH * dbl_zoom; //* ratio
		display_rect.location.x -= cy_arrow / 2 * InfoPanelView.#airport.CurrentWind.direction.sin();
		display_rect.location.y += cy_arrow / 2 * InfoPanelView.#airport.CurrentWind.direction.cos();
		ScreenManager.displayImage(sp_arrow, display_rect, InfoPanelView.#airport.CurrentWind.direction);

		//displaying undispaled sector :)
		var ratio =  (InfoPanelView.#airport.CurrentWind.DBL_MAX_WIND_SPEED - InfoPanelView.#airport.CurrentWind.speed)
			/InfoPanelView.#airport.CurrentWind.DBL_MAX_WIND_SPEED;
		display_rect.extent.height = (cy_arrow - 1) * ratio;
		display_rect.extent.width = (InfoPanelView.#WIND_ARROW_WIDTH - FrameBuilder.adaptToFrame(2))*dbl_zoom;
		ScreenManager.displayImage(sp_filler, display_rect, InfoPanelView.#airport.CurrentWind.direction);
	}

//event handlers
	static #tool_bar_item_on_click(event: ObjectEvent): void
	{
		var tbi_source: ToolBarItem = ToolBarItem(event.SourceObject);
		switch (tbi_source)
		{
			case InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_BACK_TO_MENU]:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_MENU_CLICK);
			break;
			case InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_HINT]:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_HINT_CLICK);
			break;

			case InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_INFO]:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_INFO_CLICK);
			break;

			case InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_RESTART]:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_RESTART_CLICK);
			break;
		}
	}

	static #tool_bar_item_on_paint(event: ObjectEvent): void
	{
		var tbi_source: ToolBarItem = ToolBarItem(event.SourceObject);
		var rect_tbi: Rect = tbi_source.clone();
		rect_tbi.location = rect_tbi.location.add(InfoPanelView.#tool_bar.location);
		switch (tbi_source)
		{
			case InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_LEVEL_NUMBER]:
				InfoPanelView.#display_level_number(rect_tbi);
			break;
			case InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_POINTS]:
				InfoPanelView.#display_points(rect_tbi);
			break;
			case InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_PROGRESS]:
				InfoPanelView.#display_progress_widget(rect_tbi);
			break;
			case InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_WIND_INDICATOR]:
				InfoPanelView.#display_wind_indicator_widget(rect_tbi);
			break;
		}
	}

	static #tool_bar_toggle_button_on_toggle(event: ObjectEvent): void
	{
		var tbtb_source: ToolBarToggleButton = ToolBarToggleButton(event.SourceObject);
		switch(tbtb_source) {
			case InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_FAST_PLAY]:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_FAST_SIM_CLICK, 
					{FastMode: tbtb_source.Checked});
			break;	
			case InfoPanelView.#ITEMS[InfoPanelView.#BUTTON_INDEX_PAUSE_PLAY]:
				ControlDispatcher.dispatchViewEvent(ControlDispatcher.N_INFO_PANEL_PAUSE_SIM_CLICK,
					{PauseMode: tbtb_source.Checked});
			break;			
		}
	}
	
	static #uncheck_button(obj_button)
	{
		if (!obj_button) return;
		var tbtb: ToolBarToggleButton = ToolBarToggleButton(obj_button);
		tbtb.Checked = false;
	}
}


///////////////////////////////////////////////////////////
//  Core.as
///////////////////////////////////////////////////////////

class Core //static
{
	static get FRAME_RATE() {return 15};
	static get DISPLAY_MODE_CHANGE() {return "DM"};
	
	static #prev_frame_airport_shown = false;
	static #is_timer_suspend_pending = false;

//methods
	static dispatch_event(event)
	{
		if (!MenuView.process_event(event))
			if (!HintPanelView.process_event(event))
<<<<<<<<<<<<<<<<======== Current place - level 4 ========
				if (!InfoPanelView.process_event(event))
					if (!BannerView.process_event(event))
						AirportView.process_event(event);
								
		postprocess();
	}

	static resume()
	{
		//TODO: Start of timer
		//if (timerMain) timerMain.start();
	}
	
	static run(stage) 
	{
		//TODO: Creation of timer (do we need this?)
		//timerMain = new Timer(1000 / FRAME_RATE,0)
		
		Core.suspend();
		
		//TODO: Bind timer listener (and start)
		//timerMain.addEventListener(TimerEvent.TIMER, Core.#on_timer);

		//TODO: Bind stage listeners

		// AStage.mouseChildren=false;
		// AStage.doubleClickEnabled=true;		
		// AStage.addEventListener(KeyboardEvent.KEY_UP, Stage_OnEvent);
		// AStage.addEventListener(KeyboardEvent.KEY_DOWN, Stage_OnEvent);			
		// AStage.addEventListener(MouseEvent.MOUSE_DOWN, Stage_OnEvent);
		// AStage.addEventListener(MouseEvent.MOUSE_MOVE, Stage_OnEvent);
		// AStage.addEventListener(MouseEvent.MOUSE_UP, Stage_OnEvent);
		// AStage.addEventListener(MouseEvent.CLICK, Stage_OnEvent);
		// AStage.addEventListener(MouseEvent.DOUBLE_CLICK, Stage_OnEvent);

		//stgStage = AStage;
		
		this.#resume();
	}
		
	static suspend()
	{
		//timerMain.stop();
		//TODO: Pause timer
	}

//private methods
	static #create_frame()
	{
		Profiler.checkin("Computing");

		ControlDispatcher.run();

		Profiler.checkout("Computing");		

		FrameBuilder.buildFrame();
}	
						
	static #postprocess()
	{
		if (ControlDispatcher.current_display_mode == DisplayMode.EDIT)
		{
			if (EditController.get_instance().LevelConfig)
			{	
				
				if (stgStage) stgStage.mouseChildren = true;
				isTimerSuspendPending = true;				
			}
		}		
		if (!(EditController.get_instance().LevelConfig))
		{
			if (stgStage) stgStage.mouseChildren = false;
			if (!HintPanelView.IsShown)
				this.#resume();
		}
	}					
	//event handlers

	static #stage_on_event(event) 
	{
		Core.dispatch_event(event);
	}
			
	static #on_timer(event) 
	{
		createFrame();
		
		if (isTimerSuspendPending)
		{
			isTimerSuspendPending = false;
			suspend();
		}
	}
}

class ControlDispatcher //static
{
	static #active_controller = null; //: IController
	static #display_mode = null //: DisplayMode;	
	static #title_pause = 0; //frames

//properties
	static get active_controller() //: IController
	{
		return this.#active_controller;
	}

	static set active_controller(controller)
	{
		this.#active_controller = controller;
	}	

	static get current_display_mode() //: DisplayMode
    {
    	return this.#display_mode;
    }	

	static set current_display_mode(display_mode)
	{
		if (this.#display_mode == display_mode) return;
		
		if (this.#title_pause == 0)
		{
			this.#display_mode = display_mode;
<<<<<<<<<<<<<<<<======== Current place - level 3 ========
			//TODO Event sending
			//Core.dispatch_event(new Event(Core.DISPLAY_MODE_CHANGE))
			if (MenuView.#active_controller) MenuView.#active_controller.process_dispatcher_event(OutcomingDispatcherEventTypes.DISPLAY_MODE_CHANGED, null);
			
			nTitlePause = FDisplayMode.PAUSE;
		}
	}		

//methods
	//public methods
	static dispatch_view_event(event_type: int, param_obj = null): Boolean
	{
		switch (event_type)
		{
			case IncomingDispatcherEventTypes.AIRPORT_DOUBLE_CLICK:
				return FActiveController.process_dispatcher_event(OutcomingDispatcherEventTypes.OBJECT_ACTIVATE, param_obj);
				
			case IncomingDispatcherEventTypes.AIRPORT_MOUSE_DOWN:
				if (ControlDispatcher.current_display_mode.AirportShown)
					return FActiveController.process_dispatcher_event(OutcomingDispatcherEventTypes.OBJECT_SELECT, param_obj);
				else
				{
					nTitlePause = 0;
					controlDisplayMode();
					return true;
				}

			case IncomingDispatcherEventTypes.AIRPORT_MOUSE_MOVE:
				if (ControlDispatcher.current_display_mode == DisplayMode.PLAY)
				{
					return GameController.get_instance().process_dispatcher_event(OutcomingDispatcherEventTypes.PATH_CONTINUE, param_obj);
				}
				break;

			case IncomingDispatcherEventTypes.AIRPORT_MOUSE_UP:
				if (ControlDispatcher.current_display_mode == DisplayMode.PLAY)
				{
					return FActiveController.process_dispatcher_event(OutcomingDispatcherEventTypes.PATH_FINISH, param_obj);
				}
				break;

			case IncomingDispatcherEventTypes.AIRPORT_KEY_PRESSED:
				if (param_obj.KeyCode == Keys.I)
					return FActiveController.process_dispatcher_event(OutcomingDispatcherEventTypes.OBJECT_INFO);
				else
					return FActiveController.process_dispatcher_event(N_KEY_PRESSED, param_obj);
				break;

			case IncomingDispatcherEventTypes.BANNER_BACK_CLICK:
				ControlDispatcher.current_display_mode = DisplayMode.LEVEL_MENU;
				FActiveController = MenuController.get_instance();								
				break;

			case IncomingDispatcherEventTypes.BANNER_SKIP_LEVEL_CLICK:			
				GameController.get_instance().process_dispatcher_event(OutcomingDispatcherEventTypes.NEXT_LEVEL, null);
				//fall to next case
				
			case IncomingDispatcherEventTypes.BANNER_RESTART_CLICK:
				GameController.get_instance().process_dispatcher_event(OutcomingDispatcherEventTypes.START_LEVEL, null);
				FActiveController = GameController.get_instance();
				break;

			case IncomingDispatcherEventTypes.BANNER_START_CLICK:
				GameController.get_instance().process_dispatcher_event(OutcomingDispatcherEventTypes.PLAY_LEVEL, null);
				FActiveController = GameController.get_instance();
				break;
				
			case IncomingDispatcherEventTypes.EDITOR_CORNER_CLICK:
				switch (ControlDispatcher.current_display_mode)
				{
					case DisplayMode.PLAY:
						FActiveController = EditController.get_instance();
						return true;
						
					case DisplayMode.EDIT:
						return FActiveController.process_dispatcher_event(N_LEVEL_CONFIG_VISIBILITY);
				}
				break;
				
			case IncomingDispatcherEventTypes.INFO_PANEL_MENU_CLICK:
				switch (ControlDispatcher.current_display_mode)
				{
					case DisplayMode.LEVEL_MENU:
						return FActiveController.process_dispatcher_event(N_BACK_TO_BOXES);
					case DisplayMode.PLAY:
					case DisplayMode.CRASH_PAUSE:
						nTitlePause = 0;
						GameProgress.acceptLevelResult(GameController.get_instance().shift_progress);
						ControlDispatcher.current_display_mode = DisplayMode.LEVEL_FAILED_BANNER;
				}
				break;
				
			case IncomingDispatcherEventTypes.INFO_PANEL_FAST_SIM_CLICK:	
				if (ControlDispatcher.current_display_mode == DisplayMode.PLAY)
				{
					return FActiveController.process_dispatcher_event(OutcomingDispatcherEventTypes.FAST_SIMULATION, param_obj);
				}
				break;

			case IncomingDispatcherEventTypes.INFO_PANEL_HINT_CLICK:
				if (ControlDispatcher.current_display_mode == DisplayMode.PLAY)
				{
					return FActiveController.process_dispatcher_event(OutcomingDispatcherEventTypes.SHOW_HINTS);				
				}
				break;

			case IncomingDispatcherEventTypes.INFO_PANEL_INFO_CLICK:
				ControlDispatcher.current_display_mode = DisplayMode.ABOUT_BANNER;
				break;
				
			case IncomingDispatcherEventTypes.INFO_PANEL_PAUSE_SIM_CLICK:	
				if (ControlDispatcher.current_display_mode == DisplayMode.PLAY)
				{
					return FActiveController.process_dispatcher_event(OutcomingDispatcherEventTypes.PAUSE_SIMULATION, param_obj);
				}
				break;

			case IncomingDispatcherEventTypes.INFO_PANEL_RESTART_CLICK:	
				if (ControlDispatcher.current_display_mode == DisplayMode.PLAY)
				{
					GameProgress.acceptLevelResult(GameController.get_instance().shift_progress);
					return FActiveController.process_dispatcher_event(OutcomingDispatcherEventTypes.START_LEVEL);				
				}
				break;
				
			case IncomingDispatcherEventTypes.MENU_BOX_SELECT:
				return FActiveController.process_dispatcher_event(N_BOX_OPEN, param_obj);
				
			case IncomingDispatcherEventTypes.MENU_LEVEL_SELECT:	
				if (param_obj.LevelNumber > 0)
				{
					GameProgress.selectSpecifiedLevel(param_obj.LevelNumber);
					FActiveController = GameController.get_instance();
					return FActiveController.process_dispatcher_event(OutcomingDispatcherEventTypes.START_LEVEL);
				}
				break;
		}
		return false;
	}

	static run()
	{
		controlDisplayMode();
		FActiveController.run();
	}

//private methods
	static #control_display_mode()
	{
		if (--nTitlePause <= 0)
		{
			nTitlePause = 0;
			switch (ControlDispatcher.current_display_mode)
			{
				case DisplayMode.SPLASH_SCREEN:
					ControlDispatcher.current_display_mode = DisplayMode.BOX_MENU;
					FActiveController = MenuController.get_instance();
					break;

				case DisplayMode.CRASH_PAUSE:
					GameProgress.acceptLevelResult(GameController.get_instance().shift_progress);
					ControlDispatcher.current_display_mode = DisplayMode.LEVEL_FAILED_BANNER;
					FActiveController = GameController.get_instance();
					break;					
/*				case DisplayMode.LEVEL_COMPLETE_BANNER: 
					if (GameProgress.Complete)
					{
						ControlDispatcher.current_display_mode = DisplayMode.ABOUT_BANNER;
						FActiveController = GameController.get_instance();
					}
					break;
				case DisplayMode.ABOUT_BANNER: 
					GameProgress.reset();
					ControlDispatcher.current_display_mode = DisplayMode.LEVEL_MENU;
					FActiveController = MenuController.get_instance();					
					break;
					*/
				case DisplayMode.MISSION_COMPLETE_PAUSE:
					ControlDispatcher.current_display_mode = GameProgress.IsLastBox && GameProgress.BoxPassed ? 
						DisplayMode.ABOUT_BANNER 
						: DisplayMode.LEVEL_COMPLETE_BANNER;
					FActiveController = GameController.get_instance();
					break;										
				case DisplayMode.PLAY:
					if (GameController.get_instance().shift_progress >= 100)
					{
						GameProgress.acceptLevelResult(100);					
						ControlDispatcher.current_display_mode = DisplayMode.MISSION_COMPLETE_PAUSE;
						FActiveController = GameController.get_instance();
					}
					break;
			}
		}
	}
}}


///////////////////////////////////////////////////////////
//  FrameBuilder.as
///////////////////////////////////////////////////////////

class FrameBuilder //static
{
	static before_rescale; //TODO: event
	static get CY_INFO_PANEL_HEIGHT() {return 24.0};
	static get DBL_STANDARD_FRAME_HEIGHT() {return 400};
	static get DBL_STANDARD_FRAME_WIDTH() {return 550};
	static get N_MARGIN_WIDTH() {return 300};
	
	//property fields
	static #frame_rect = null;
	static #game_zone_rect = null;
	static #info_panel_rect = null;
	
	//Определяет, где на экране находится точка отсчета координат аэродрома
	//Задается в: 
	//	FrameBuilder.init
	//	FrameBuilder.scaleScene
	//Используется в:
	//	функциях конвертации между моделью и игровой зоной
	static #origin = null;
	static #performance_metrics_shown = false;
	static #zoom = null;	
	
	//other fields
	static #airport = null;
	static #dbl_frame_adaptation_ratio = 1;
	static #dt_frame_count = new Date(0);
	static #n_frame_count = 0;
	static #n_frames_per_second = 0;

//properties
	//
	//location = {0,0}
	//extent = {stage.stageWidth, stage.stageHeight}
	//Задается в: get FrameRect
	//Не изменяется ли динамически 
	//Используется в: 
	//	FrameBuilder.drawMargin
	//	AircraftView.draw
	//  HintPanelView.show
	//  HintPanelView.getHintPanelRect
	//Всегда ли равен по ширене GameZone.extent.width?
	static get frame_rect() //: Rect
	{
		return this.#frame_rect;
	}
	
	//Прямоугольник игровой области в единицах сцены Flash без величины панели
	//Задается как: FrameRect - info_panel_rect
	//Не изменяется ли динамически 
	//Всегда равен FrameRect за вычетом панели
	//Используется в:
	//	AircraftView.displayArrivalMark
	//	AirportView.processMouseEvent
	//  MenuView.get_menu_parameters
	static get game_zone_rect() //: Rect
	{
		return this.#game_zone_rect;
	}
	//Прямоугольник инфопанели в единицах сцены Flash
	//Задается как:
	//	location = new Point(0, 0);
	//	extent = new Size(InfoPanelView.height, InfoPanelView.height);
	//Не изменяется ли динамически 
	//Всегда равен FrameRect за вычетом панели
	//Используется в:
	//	InfoPanelView.display
	//	InfoPanelView.setButtonRects
	static get info_panel_rect() //: Rect
	{
		return this.#info_panel_rect;
	}

	static set performance_metrics_shown(value) 
	{
		this.#performance_metrics_shown = value;
	}	

	static get zoom() //: Number
	{
		return this.#zoom;
	}
	
//methods
	//public methods
	static adapt_to_frame(length) //: Number 
	{
		return length * FrameBuilder.#dbl_frame_adaptation_ratio;
	}
	
	static adapt_size_to_frame(size) //: Size 
	{
		return new Size (size.width * FrameBuilder.#dbl_frame_adaptation_ratio, size.height * FrameBuilder.#dbl_frame_adaptation_ratio);
	}

	static build_frame() 
	{
		set_frame_dimensions(ScreenManager.create_frame());

<<<<<<<<<<<<<<<<======== Current place - level 2 ========
		if (!ControlDispatcher.current_display_mode.is_splash_screen) {
			displayGameZoneBackground();
		}
		
		if (ControlDispatcher.current_display_mode.AirportShown) {
			AirportView.display(FrameBuilder.#airport, ControlDispatcher.active_controller.get_controller_type() == 0);
			StarView.display();
		}
		
		if (ControlDispatcher.current_display_mode.MenuShown) {
			MenuView.display();
		}

		if (ControlDispatcher.current_display_mode.BannerShown) {
			BannerView.display();
		}

		if (ControlDispatcher.current_display_mode == DisplayMode.EDIT) {
			var edit_controller: EditController = EditController.get_instance();
			if (edit_controller.LevelConfig) {
				displayLevelConfig(edit_controller.LevelConfig);
			}
		}
		
		HintPanelView.display();
		
		if (!ControlDispatcher.current_display_mode.IsSplashScreen) {
			InfoPanelView.display(FrameBuilder.#airport);
			
			displayFrameMargins();
		}

		if (FPerformanceMetricsShown)
			displayPerformanceMetrics();
			
		
	}
	
	static center_in_frame(ARect: Rect): Rect
	{
		var rect_result = ARect.clone();
		rect_result.location.x = (FFrameRect.extent.width - rect_result.extent.width) / 2;
		rect_result.location.y = (FFrameRect.extent.height - rect_result.extent.height) / 2;
		return rect_result;
	}

	static convert_to_model_length(length): //Number 
	{
		return length * FZoom;
	}
	
	static convert_to_model_point(point: Point): Point
	{
		return new Point((point.x - FOrigin.x) * FZoom, (point.y - FOrigin.y - FrameBuilder.#info_panel_rect.extent.height) * FZoom);
	}
	
	static convert_to_model_rect(ARect: Rect): Rect
	{
		return new Rect (convertToModelPoint(ARect.location), convertToModelSize(ARect.extent));
	}
	
	static convert_to_model_size(size: Size): Size 
	{
		return new Size(convertToModelLength(size.width), convertToModelLength(size.height));
	}
	
	static convert_to_screen_length(length): //Number
	{
		return length / FZoom;
	}
	
	static convert_to_screen_point(point: Point): Point
	{
		return new Point(point.x / FZoom + FOrigin.x, point.y / FZoom + FOrigin.y + FrameBuilder.#info_panel_rect.extent.height);
	}
	
	static convert_to_screen_rect(ARect: Rect): Rect 
	{
		return new Rect (convertToScreenPoint(ARect.location), convertToScreenSize(ARect.extent));
	}
	
	static convert_to_screen_size(size: Size): Size
	{
		return new Size(convertToScreenLength(size.width), convertToScreenLength(size.height));
	}		
				
	static init(airport)		
	{
		FrameBuilder.#airport = airport;		

		FOrigin = new Point();
		FrameBuilder.#airport.OnResized.addEventListener(CustomDispatcher.ON_RESIZED, Airport_OnResized);
	}

	static fit_to_frame(ARect: Rect): Rect
	{
		var rect_result = ARect.clone();
		var dbl_hor_scale = FFrameRect.extent.width / ARect.extent.width;    //10x50 / 500x100 //50
		var dbl_ver_scale = FFrameRect.extent.height / ARect.extent.height;//2
		var dbl_scale = Math.min(dbl_hor_scale, dbl_ver_scale);
		rect_result.extent.width *= dbl_scale; 
		rect_result.extent.height *= dbl_scale;			
		
		return centerInFrame(rect_result);
	}
//private methods

	static #display_frame_margins()
	{
		Profiler.checkin("margins");
		for (var x = -1; x <= 1; x++)
			for (var y = (x ? 0: -1); y <= (x ? 0 : 1); y+=2)
				displayMargin(x, y);
		
		//рамка	
		ScreenManager.display_image(new BorderImage(), this.#game_zone_rect);
		Profiler.checkout("margins");
	}

	static #display_game_zone_background()
	{
		Profiler.checkin("background");
		ScreenManager.display_image(new GameZoneBgImage(), this.#game_zone_rect);
		Profiler.checkout("background");
	}
	
	static #display_level_config(AConfig: XML)
	{
		ScreenManager.displayText(AConfig.to_string(), new Rect(new Point(20, 50), new Size(500, -1)), 
			FrameBuilder.adapt_to_frame(ScreenManager.FONT_SIZE_MEDIUM), Colors.White, true, true)		
	}	

	static #display_margin(x: int, y: int)
	{
		var dbl_margin_width = FrameBuilder.adapt_to_frame(N_MARGIN_WIDTH);
		var x = x ? ((x < 0) ? -dbl_margin_width : FrameBuilder.FrameRect.extent.width): 0;
		var y = y ? ((y < 0) ? -dbl_margin_width : FrameBuilder.FrameRect.extent.height): 0;
		var cx = x ? dbl_margin_width : FrameBuilder.FrameRect.extent.width;
		var cy = y ? dbl_margin_width : FrameBuilder.FrameRect.extent.height;		
	
		ScreenManager.display_image(new MarginImage(), new Rect(new Point(x, y), new Size(cx, cy)));
	}

	static #display_performance_metrics() 
	{
		nFrameCount++;
		var dt = new Date();
		if (dt.getTime() - dtFrameCount.getTime() > 1000)
		{	
			nFramesPerSecond = nFrameCount;
			nFrameCount = 0;
			dtFrameCount = dt;
		}	
		
		var str_text: String = "FPS: " + nFramesPerSecond.to_string() 
		+ "\nDisplaying:"
		+ "\n\t" + Profiler.getWatch("background")
		+ "\n\t" + Profiler.getWatch("margins")
		+ "\n\t" + Profiler.getWatch("airport")
		+ "\n\t\t" + Profiler.getWatch("aprons")
		+ "\n\t\t" + Profiler.getWatch("gates")
		+ "\n\t\t" + Profiler.getWatch("airfields")
		+ "\n\t\t" + Profiler.getWatch("aircrafts")
		+ "\n\t\t\t" + Profiler.getWatch("balloons")
		+ "\n\t\t\t" + Profiler.getWatch("shadows")
		+ "\n\t\t\t" + Profiler.getWatch("headlights")
		+ "\n\t\t\t" + Profiler.getWatch("bodies")
		+ "\n\t\t\t" + Profiler.getWatch("gauges")	
		+ "\n\t\t\t" + Profiler.getWatch("paths")
		+ "\n\t" + Profiler.getWatch("menu")
		+ "\n\t" + Profiler.getWatch("hint")
		+ "\n\t" + Profiler.getWatch("banner")
		+ "\n" + Profiler.getWatch("Computing")
		+ "\nDisplay objects: " + ScreenManager.DisplayObjectsCount;
		ScreenManager.displayText(str_text, new Rect(new Point(50, 50), new Size(-1, -1)), FrameBuilder.adapt_to_frame(ScreenManager.FONT_SIZE_SMALL));
	}
		
	static #scale_scene()
	{
		BeforeRescale.fireBeforeRescale();
		
		FZoom = FrameBuilder.#airport.extent.width/this.#game_zone_rect.extent.width;//after fix FrameBuilder.#airport.CY / cyScreen == FrameBuilder.#airport.CX / cxScreen
		//1. 0 аэропорта совпадает с 0 экрана
		//2. - FrameBuilder.#airport.x/FZoom - сдвигаем 0 аэропорта чтобы 0 экрана совпал с левой границей аэропорта
		//3. FrameBuilder.#airport.CX/FZoom  - получаем размер аэропорта в экранном размере
		//4. cxScreen -                    - получаем лишнее, свободное место экрана не занятое аэропортом
		//5. /2.0                          - делим лишнее место, чтобы получить ширину поля слева (справа будет равное)
		//6. +                             - сдвигаем аэропорт на ширину левого поля 
		FOrigin.x = - FrameBuilder.#airport.location.x/FZoom + (this.#game_zone_rect.extent.width - FrameBuilder.#airport.extent.width/FZoom)/2.0;
		FOrigin.y = - FrameBuilder.#airport.location.y/FZoom + (this.#game_zone_rect.extent.height - FrameBuilder.#airport.extent.height/FZoom)/2.0;		
	}

	static #set_frame_dimensions(AFrameSize: Size)
	{
		FFrameRect = new Rect(new Point(), ScreenManager.StageSize);	

		if (FFrameRect.extent.width > FFrameRect.extent.height)
			dblFrameAdaptationRatio = FFrameRect.extent.height / DBL_STANDARD_FRAME_HEIGHT;
		else
			dblFrameAdaptationRatio = FFrameRect.extent.width / DBL_STANDARD_FRAME_WIDTH;

		FrameBuilder.#info_panel_rect = new Rect(new Point(), new Size(FFrameRect.extent.width, FrameBuilder.adapt_to_frame(CY_INFO_PANEL_HEIGHT)));		
		
		var sz_game_zone: Size = ScreenManager.StageSize.clone();
		sz_game_zone.height -= FInfoPanelRect.extent.height;
		this.#game_zone_rect = new Rect(new Point(0, FInfoPanelRect.extent.height), sz_game_zone);		
	}

	//event handlers	
	static #airport_on_resized(event) //:void 
	{
		scaleScene();
	}
}



function start()
{
		let airport = new Airport();
		console.log("Executed!!!");
<<<<<<<<<<<<<<<<======== Current place - level 1 ========
		FrameBuilder.init(airport);

		ControlDispatcher.current_display_mode = DisplayMode.SPLASH_SCREEN;
		MenuController.get_instance();
		ControlDispatcher.ActiveController = GameController.get_instance(airport);
		EditController.get_instance(airport);
		
		Core.run(AStage);
}
