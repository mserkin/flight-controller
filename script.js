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
//v˙=Y/m−g⋅sin(ϕ)⋅cos(θ)−r⋅u+p⋅w
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
//v˙=Y/m−g⋅sin(ϕ)⋅cos(θ)−r⋅u+p⋅w
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

class Enum {
	// приватный конструктор, чтобы никто не создавал экземпляры
	constructor(name, value) {
	  this.#name = name;
	  this.#value = value;
	  Object.freeze(this); // делаем объект константой
	}
  
	toString() {
	  return this.#name;
	}
  
	valueOf() {
	  return this.#value;
	}
}
  
class AngleUnits extends Enum {
	static RADIAN = new AngleUnits("RADIAN", 0);
	static DEGREE = new AngleUnits("DEGREE", 1);
  
	static values() {
	  return [this.RADIAN, this.DEGREE];
	}
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

	#value

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
				throw new Error("Illegal unit:" + unit.toString());
		}
		this.normalize();
	} 

// properties
	get DBL_ROTATION_ERROR() 
	{
		return Angle.#DBL_ROTATION_ERROR
	}

	static get HalfPI() //: Angle
	{
		return new Angle(Math.PI / 2, AngleUnits.RADIAN);
	}

	static get MinusHalfPI() //: Angle
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
		var x_diff = (point_to.X - point_from.X);		
		var y_diff = -(point_to.Y - point_from.Y);
		var dbl_dist = Math.sqrt(x_diff*x_diff + y_diff*y_diff);
		var ang_target = Angle.arcsin(x_diff/dbl_dist);  	
		if (y_diff < 0) ang_target.radian = Math.PI - ang_target.radian;
		
		if (distance_obj)
			distance_obj.distance = dbl_dist;
			
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

//Rect с Location в центре, повернутый на угол Rotation
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
				//var ang_fix: Angle = new Angle(pnt_corner.Theta.Radian - Math.PI / 2 * i_width); 
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

//Выделяемый Region с Location в центре
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
			+ super.toString(indent + 1) 
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
//  set selected(IsSelected: Boolean)	
//	get upwind_course() //: Angle;
//	get width() //: Number;
//methods
//  exchangeGate(gate, location) //: Gate;
//  free(aircraft) //: void;
//  getRegion() //: Region;
//  inArea(point);
//  inLandingZone(point) //: Boolean;
//  occupyToLand(aircraft) //: Gate;
//  occupyToTakeoff(aircraft) //: Boolean;
//  toString(indent=0) //: String;
//  toXml(xml_node);
//  updateWind(wind_direction);


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
			//trace('!!!FActiveCourse=' + FActiveCourse.Degree);
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
		let ang_course: Angle = this.course.clone();
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

class Airport {
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
		//this.OnGateLoaded : CustomDispatcher = new CustomDispatcher();
		//this.OnLevelLoaded: CustomDispatcher = new CustomDispatcher();
		//this.OnResized: CustomDispatcher = new CustomDispatcher();
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
		//TODO: load level continuation let xml_doc = new XML(ulLoader.data);
		//ulLoader.close();

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
	//URLLoader_OnComplete(AnEvent: Event): void
	//{
	//	loadLevelCont();
	//}
}

function start()
{
		let ap_airport = new Airport();
		console.log("Executed!!!");
				<<=========== HERE
		FrameBuilder.init(ap_airport);

		ControlDispatcher.CurrentDisplayMode = DisplayMode.SplashScreen;
		MenuController.getInstance();
		ControlDispatcher.ActiveController = GameController.getInstance(ap_airport);
		EditController.getInstance(ap_airport);
		
		Core.run(AStage);
}
