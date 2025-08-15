//import { SVGLoader } from 'three/examples/jsm/loaders/SVGLoader.js';
//const loader = new SVGLoader();

var canvasWidth = window.innerWidth;
var canvasHeight = window.innerHeight;

const xAxis = new THREE.Vector3(1, 0, 0);
const yAxis = new THREE.Vector3(0, 1, 0);
const zAxis = new THREE.Vector3(0, 0, 1);

const renderer = new THREE.WebGLRenderer({antialias: true}); //THREE.WebGLRenderer( { stencil: true } );
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
//const light1 = new THREE.DirectionalLight(0xffffff, 1.0);
//const light1 = new THREE.PointLight(0xffffff, 3, 0, 0);
const light1 = new THREE.SpotLight(0xffffff, 1.0);

light1.position.set(0, 5, 0); //.normalize();
light1.lookAt(scene.position);

const lightTarget = new THREE.Object3D(); 
lightTarget.position.set(0, 0, 0);
light1.target = lightTarget;

//light1.target.position.set(0, 0, 0);
//light1.target.position.set(0, 0, 0); //.applyQuaternion(light1.quaternion);
//light1.target.updateMatrixWorld();

light1.castShadow = true;
light1.shadow.radius = 5;
light1.shadow.blurSamples = 1;
light1.shadow.mapSize.width = 512
light1.shadow.mapSize.height = 512;

//---for DirectionalLight (OrthographicCamera)---
light1.shadow.camera.left = -5; //-5;
light1.shadow.camera.right = 5; //5;
light1.shadow.camera.top = 5; //5;
light1.shadow.camera.bottom = -5; //-5;
light1.shadow.bias = -0.0;
//---for PointLight or SpotLight (PerspectiveCamera)---
light1.shadow.camera.fov = 90; //90;
light1.shadow.camera.aspect = 1; //1;
light1.shadow.camera.near = 0.1; //0.5;
light1.shadow.camera.far = 10; //500;

//light1.shadow.camera.lookAt(scene.position);
//light1.shadow.camera.updateProjectionMatrix();
//light1.shadow.needsUpdate = true;
//light1.shadow.updateMatrices(light1);

scene.add(light1);
//scene.add(lightTarget);

//scene.traverse((child) => {if(child.material) child.material.needsUpdate=true});

const helper = new THREE.CameraHelper(light1.shadow.camera);
scene.add(helper);

//===Camera===
var camRadius = 15;
const camAngleDown = new THREE.Vector3();
const camAngle = new THREE.Vector3();
camAngle.x = 45;
camAngle.y = 30;
camAngle.z = 45;
camera = new THREE.PerspectiveCamera(20, canvasWidth / canvasHeight, 0.1, 1000);
camera.aspect = canvasWidth / canvasHeight; 
camera.updateProjectionMatrix();
function cameraPositionUpdate() {
	camera.position.x = camRadius * Math.sin(THREE.MathUtils.degToRad(camAngle.x)) * Math.cos(THREE.MathUtils.degToRad(camAngle.y));
	camera.position.z = camRadius * Math.cos(THREE.MathUtils.degToRad(camAngle.x)) * Math.cos(THREE.MathUtils.degToRad(camAngle.y));
	camera.position.y = camRadius * Math.sin(THREE.MathUtils.degToRad(camAngle.y));
	light0.position.set(camera.position.x, camera.position.y, camera.position.z).normalize();
	camera.lookAt(scene.position);
}
cameraPositionUpdate();

//===Raycaster===
raycaster = new THREE.Raycaster();

//===Sphere===
const sphereGeometry = new THREE.SphereGeometry(40, 32, 16);
const sphereMaterial = new THREE.MeshLambertMaterial({color: 0x000055});
//clipMaterial = new THREE.MeshBasicMaterial({
clipMaterial = new THREE.MeshPhongMaterial({
	color: 0x000040,
	shininess: 100,
	side: THREE.DoubleSide,
});
const sphere = new THREE.Mesh(sphereGeometry, clipMaterial);
scene.add(sphere);

//===SVG===
const svgCode = '<svg viewBox="0 0 11100 8000"><path d="M10893 1895c86,6 153,90 153,190l0 1125c0,52 -33,96 -78,103l-47 8c-4,1 -8,1 -13,1 -20,0 -40,-8 -54,-23 -15,-15 -23,-34 -23,-55l0 -11 -2975 418c-1,0 1,0 0,0l-1798 0c-17,170 -37,343 -60,515l-252 1926 1311 238c23,4 -2,-41 21,-41 60,1 111,57 111,123l0 704c0,35 -24,64 -56,69l-32 5c-30,5 -36,-15 -42,-43l-1242 174 -180 -391 -8 64c-1,9 -4,17 -8,25l-37 900c-1,20 -17,35 -36,35 -20,0 -36,-16 -36,-35l-25 -898c-5,-9 -8,-18 -9,-28l-6 -49 -174 377 -1242 -174c-2,11 -8,21 -16,29 -11,10 -25,15 -39,15 -3,0 -6,0 -9,-1l-32 -5c-32,-5 -57,-35 -57,-69l0 -704c0,-65 48,-119 108,-123l3 0c24,0 43,18 43,41l0 0 1311 -238 -250 -2069c-14,-126 -27,-251 -38,-372l-1844 0 -2975 -418 0 11c0,21 -8,41 -23,55 -15,15 -34,23 -54,23 -4,0 -8,0 -13,-1l-47 -8c-45,-8 -78,-51 -78,-103l0 -1125c0,-100 67,-183 153,-190 33,-3 62,24 62,58l0 40 2947 -193 1780 0c5,-141 12,-282 22,-423l51 -759c5,-106 99,-191 203,-191l110 0 0 -30 -22 0c-9,0 -17,-5 -21,-13 -4,-8 -4,-17 1,-25l57 -94 -62 0c-17,0 -31,-11 -37,-26l-873 0 0 -29 873 0c6,-15 20,-26 37,-26l111 0 87 -120c9,-15 33,-15 42,0l70 119 107 0c17,0 31,11 37,26l873 0 0 29 -873 0c-6,15 -20,26 -37,26l-59 0 55 94c5,8 5,17 0,25 -4,8 -12,12 -21,12l-23 0 0 30 115 0c107,0 197,84 204,192l50 784c9,136 15,270 20,398l1801 0 2947 193 0 -40c0,-33 29,-60 62,-58z"/></svg>';
const svgContainer = document.getElementById('svg-container');
//svgContainer.innerHTML = svgCode;

//===Plane===
const planeShape = new THREE.Shape();
//planeShape.Ellipse(-0.3, 5, 0.3, 3);
//planeShape.Rectangle(-0.3, 4, 0.3, -2);
//planeShape.Rectangle(-0.5, 3, 0.3, 0);
planeShape.moveTo(-0.3, -2);
planeShape.lineTo(-0.2, -2.7);
planeShape.lineTo(-1.8, -4);
planeShape.lineTo(-2, -4.5);
planeShape.lineTo(-0.1, -3.7);
planeShape.lineTo(0, -5);
planeShape.lineTo(0.1, -3.7);
planeShape.lineTo(2, -4.5);
planeShape.lineTo(1.8, -4);
planeShape.lineTo(0.2, -2.7);
planeShape.lineTo(0.3, -2);
planeShape.lineTo(0.3, 0);
planeShape.lineTo(0.5, 0);

planeShape.lineTo(0.5, 0.5);
planeShape.lineTo(1.3, 0.3);
planeShape.lineTo(5.1, -1.3);
planeShape.lineTo(5, -0.7);
planeShape.lineTo(0.5, 2.7);

planeShape.lineTo(0.5, 3);
planeShape.lineTo(0.3, 3);
planeShape.lineTo(0.3, 4);
planeShape.bezierCurveTo(0.3, 4, 0.3, 5, 0, 5);
planeShape.bezierCurveTo(0, 5, -0.3, 5, -0.3, 4);
planeShape.lineTo(-0.3, 4);
planeShape.lineTo(-0.3, 3);
planeShape.lineTo(-0.5, 3);

planeShape.lineTo(-0.5, 2.7);
planeShape.lineTo(-5, -0.7);
planeShape.lineTo(-5.1, -1.3);
planeShape.lineTo(-1.3, 0.3);
planeShape.lineTo(-0.5, 0.5);

planeShape.lineTo(-0.5, 0);
planeShape.lineTo(-0.3, 0);
planeShape.lineTo(-0.3, -2);

const extrudeSettings = {
	steps: 8,
	depth: 0.5,
	bevelEnabled: true,
	bevelSize: 0.2,
	bevelSegments: 8,
	bevelThickness: 0.2,
	bevelOffset: 0
};
const planeGeometry = new THREE.ExtrudeGeometry(planeShape, extrudeSettings);
const planeMaterial = new THREE.MeshLambertMaterial({color: 0xA0A0A0});
const plane = new THREE.Mesh(planeGeometry, planeMaterial);
plane.castShadow = true;
plane.position.y = 1.5;
plane.position.z = -0.1;
plane.rotation.x = Math.PI / 2;
plane.scale.set(0.1,0.1,0.1);
scene.add(plane);

planeAngle = 0;
planeRadius = 6;
planeAltitude = 0.3;

planeYaw = 0;
planePitch = 0;
planeRoll = 0;

function planePositionUpdate() {
	plane.position.x = planeRadius * Math.sin(THREE.MathUtils.degToRad(planeAngle)) * Math.cos(THREE.MathUtils.degToRad(planeAngle));
	plane.position.z = planeRadius * Math.cos(THREE.MathUtils.degToRad(planeAngle)) * Math.cos(THREE.MathUtils.degToRad(planeAngle)) - planeRadius / 2;
	
	planeAltitude += planePitch / 1000;
	plane.position.y = planeAltitude;

    plane.rotation.x = Math.PI / 2;;
    plane.rotation.y = 0;
    plane.rotation.z = 0;

//    plane.rotation.z = THREE.MathUtils.degToRad(-planeAngle * 2 - 90);

    plane.rotateOnWorldAxis(xAxis, THREE.MathUtils.degToRad(-planePitch)); //pitch
    plane.rotateOnWorldAxis(zAxis, THREE.MathUtils.degToRad(-20)); //roll
    plane.rotateOnWorldAxis(yAxis, THREE.MathUtils.degToRad(planeAngle * 2 + 90)); //yaw

//    plane.rotation.y = THREE.MathUtils.degToRad(planeAngle);
}

//===Star===
//const randomPoints = [];
//for (let i = 0; i < 10; i++) {
//	randomPoints.push(new THREE.Vector3((i - 4.5) * 5, THREE.MathUtils.randFloat(-5, 5), THREE.MathUtils.randFloat(-5, 5)));
//}
//const randomSpline = new THREE.CatmullRomCurve3(randomPoints);

const starExtrudeSettings = {
	steps: 8,
	depth: 1,
	bevelEnabled: true,
	bevelThickness: 0.2,
	bevelSize: 0.4,
	bevelSegments: 1
//	extrudePath: randomSpline
};
const starPoints = [];
const starPointsCount = 7;
for (let i = 0; i < starPointsCount * 2; i++) {
	const n = i % 2 == 1 ? 1 : 2;
	const a = i / starPointsCount * Math.PI;
	starPoints.push(new THREE.Vector2(Math.cos(a) * n, Math.sin(a) * n));
}
const starShape = new THREE.Shape(starPoints);
const starGeometry = new THREE.ExtrudeGeometry(starShape, starExtrudeSettings);
const starMaterial0 = new THREE.MeshLambertMaterial({color: 0xc00000, wireframe: false});
const starMaterial1 = new THREE.MeshLambertMaterial({color: 0xff8000, wireframe: false});
const starMaterials = [starMaterial0, starMaterial1];

const star = new THREE.Mesh(starGeometry, starMaterials);
star.position.z = -0.5;
scene.add(star);

//===Field===
const fieldMaterial0 = new THREE.MeshLambertMaterial({color: 0x009000});
const fieldMaterial1 = new THREE.MeshLambertMaterial({color: 0x007000});
const fieldGeometry = new THREE.BoxGeometry(1, 1, 0.01);
const field = [];
for (let i = 0; i < 81; i++) {
  if (i % 2 == 0) {
	field.push(new THREE.Mesh(fieldGeometry, fieldMaterial0));
  } else {
	field.push(new THREE.Mesh(fieldGeometry, fieldMaterial1));
  }
  field[i].receiveShadow = true;
  field[i].rotation.x = Math.PI / 2;
  field[i].position.x = (i % 9) - 4;
  field[i].position.z = ~~(i / 9) - 4;
  scene.add(field[i]);
}

//===Event listeners===
const pointer = new THREE.Vector2();
const pointerDown = new THREE.Vector2();const pointerPrev = new THREE.Vector2();
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
	isPointerDown = true;
}

document.addEventListener('pointerup', onPointerUp);
document.addEventListener('pointercancel', onPointerUp);
function onPointerUp(event) {
	isPointerDown = false;
}

document.addEventListener('pointermove', onPointerMove);
function onPointerMove(event) {
	var scale = 180;
	pointerPrev.x = pointer.x;
	pointerPrev.y = pointer.y;
	pointer.x = (event.clientX / canvasWidth ) * 2 - 1;
	pointer.y = -(event.clientY / canvasHeight ) * 2 + 1;
	if (isPointerDown) {
		camAngle.x = camAngleDown.x - (pointer.x-pointerDown.x) * scale; if (camAngle.x < 0) camAngle.x += 360; if (camAngle.x > 360) camAngle.x -= 360;
		camAngle.y = camAngleDown.y - (pointer.y-pointerDown.y) * scale; if (camAngle.y < 0) camAngle.y = 0; if (camAngle.y > 90) camAngle.y = 90;
		cameraPositionUpdate();
	}
	raycaster.setFromCamera(pointer, camera);	
}

document.addEventListener('mousewheel', onMouseWheel);
function onMouseWheel(event) {
	camRadius -= event.wheelDelta / 100; if (camRadius < 8) camRadius = 8; if (camRadius > 32) camRadius = 32;
	cameraPositionUpdate();
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
//	const aspect = window.innerWidth / window.innerHeight;
//	camera.left = - frustumSize * aspect / 2;
//	camera.right = frustumSize * aspect / 2;
//	camera.top = frustumSize / 2;
//	camera.bottom = - frustumSize / 2;
}

//===Renderer===
var render = function () {
    setTimeout(function() {
        requestAnimationFrame(render);
    	if (!isPointerDown) {
        	camAngle.x += 0.1;
			cameraPositionUpdate();
		}

    	planeAngle += 0.5;
    	if (planeAngle >= 360) {
    		planeAngle -= 360;
    	}
//    	planeAltitude = Math.sin(THREE.MathUtils.degToRad(planeAngle * 4)) + 1.1;
    	planePitch = Math.sin(THREE.MathUtils.degToRad(planeAngle * 3)) * 30;
		planePositionUpdate();
	}, 1000 / 60);

    renderer.render(scene, camera);
}

render();