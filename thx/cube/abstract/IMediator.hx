package thx.cube.abstract;

interface IMediator {
	function preRegister() : Void;
	function onRegister() : Void;
	function preRemove() : Void;
	function onRemove() : Void;
	function getViewComponent() : Dynamic;
	function setViewComponent( viewComponent : Dynamic ) : Void;
}
