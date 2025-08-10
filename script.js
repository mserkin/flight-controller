const width = 640; //window.innerWidth;
const height = 640; //window.innerHeight;

const pointer = new THREE.Vector2();
const pointerDown = new THREE.Vector2();
const pointerPrev = new THREE.Vector2();
var isPointerDown = false;

var camRad = 25;
const camAngle = new THREE.Vector3();
const camAngleDown = new THREE.Vector3();

raycaster = new THREE.Raycaster();

const renderer = new THREE.WebGLRenderer({antialias: true});
renderer.setSize(width, height); 
renderer.setPixelRatio(window.devicePixelRatio);
renderer.setAnimationLoop(render);
document.body.appendChild(renderer.domElement);

//===Scene===
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x000000);

//===Lights===
const light01 = new THREE.DirectionalLight(0xffffff, 1);
light01.position.set(0, 0, 0).normalize();
light01.castShadow = true;
scene.add(light01);

const light02 = new THREE.DirectionalLight(0x808080, 1);
light02.position.set(0, 5, 0).normalize();
scene.add(light02);

//===Camera===
const aspect = window.innerWidth / window.innerHeight;
camera = new THREE.PerspectiveCamera(20, 1, 0.1, 1000);
camAngle.x = 45;
camAngle.y = 30;
camAngle.z = 45;
camera.position.x = camRad * Math.sin(THREE.MathUtils.degToRad(camAngle.x)) * Math.cos(THREE.MathUtils.degToRad(camAngle.y));
camera.position.z = camRad * Math.cos(THREE.MathUtils.degToRad(camAngle.x)) * Math.cos(THREE.MathUtils.degToRad(camAngle.y));
camera.position.y = camRad * Math.sin(THREE.MathUtils.degToRad(camAngle.y));

light01.position.set(camera.position.x, camera.position.y, camera.position.z).normalize();

camera.lookAt(scene.position);

//===Sphere===
const sphereGeometry = new THREE.SphereGeometry(40, 32, 16);
const sphereMaterial = new THREE.MeshLambertMaterial({color: 0x555555});
//clipMaterial = new THREE.MeshBasicMaterial({
clipMaterial = new THREE.MeshPhongMaterial({
	color: 0x404040,
	shininess: 100,
	side: THREE.DoubleSide,
});
const sphere = new THREE.Mesh(sphereGeometry,clipMaterial)
scene.add(sphere);

const squareMaterial = new THREE.MeshLambertMaterial({color: 0xFF0000});
const squareGeometry = new THREE.BoxGeometry(1, 1, 0.02);
const square = new THREE.Mesh(squareGeometry, squareMaterial);

scene.add(square);

//===Event listeners===

document.addEventListener('pointerdown', onPointerDown);
function onPointerDown(event) {
	pointerDown.x = (event.clientX / window.innerWidth ) * 2 - 1;
	pointerDown.y = -(event.clientY / window.innerHeight ) * 2 + 1;
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
	pointer.x = (event.clientX / window.innerWidth ) * 2 - 1;
	pointer.y = -(event.clientY / window.innerHeight ) * 2 + 1;
	if (isPointerDown) {
//		camAngle.x -= (pointer.x-pointerPrev.x) * mul; if (camAngle.x < 0) camAngle.x += 360; if (camAngle.x > 360) camAngle.x -= 360;
//		camAngle.y -= (pointer.y-pointerPrev.y) * mul; if (camAngle.y < 0) camAngle.y = 0; if (camAngle.y > 90) camAngle.y = 90;

		camAngle.x = camAngleDown.x - (pointer.x-pointerDown.x) * scale; if (camAngle.x < 0) camAngle.x += 360; if (camAngle.x > 360) camAngle.x -= 360;
		camAngle.y = camAngleDown.y - (pointer.y-pointerDown.y) * scale; if (camAngle.y < 0) camAngle.y = 0; if (camAngle.y > 90) camAngle.y = 90;
    	
		camera.position.x = camRad * Math.sin(THREE.MathUtils.degToRad(camAngle.x)) * Math.cos(THREE.MathUtils.degToRad(camAngle.y));
		camera.position.z = camRad * Math.cos(THREE.MathUtils.degToRad(camAngle.x)) * Math.cos(THREE.MathUtils.degToRad(camAngle.y));
		camera.position.y = camRad * Math.sin(THREE.MathUtils.degToRad(camAngle.y));
		
		light01.position.set(camera.position.x, camera.position.y, camera.position.z).normalize();

		camera.lookAt(scene.position);
	}
	
	raycaster.setFromCamera(pointer, camera);	
}

document.addEventListener('mousewheel', onMouseWheel);
function onMouseWheel(event) {
	camRad -= event.wheelDelta / 100; if (camRad < 8) camRad = 8; if (camRad > 32) camRad = 32;
	camera.position.x = camRad * Math.sin(THREE.MathUtils.degToRad(camAngle.x)) * Math.cos(THREE.MathUtils.degToRad(camAngle.y));
	camera.position.z = camRad * Math.cos(THREE.MathUtils.degToRad(camAngle.x)) * Math.cos(THREE.MathUtils.degToRad(camAngle.y));
	camera.position.y = camRad * Math.sin(THREE.MathUtils.degToRad(camAngle.y));
	camera.lookAt(scene.position);	
}

var render = function () {
    requestAnimationFrame(render);

    if (!isPointerDown) {
        camAngle.x += 0.1;
		camera.position.x = camRad * Math.sin(THREE.MathUtils.degToRad(camAngle.x)) * Math.cos(THREE.MathUtils.degToRad(camAngle.y));
		camera.position.z = camRad * Math.cos(THREE.MathUtils.degToRad(camAngle.x)) * Math.cos(THREE.MathUtils.degToRad(camAngle.y));
		camera.position.y = camRad * Math.sin(THREE.MathUtils.degToRad(camAngle.y));
		light01.position.set(camera.position.x, camera.position.y, camera.position.z).normalize();
		camera.lookAt(scene.position);
	}
		
    renderer.render(scene, camera);
}

render();