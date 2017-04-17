import { NativeModules } from 'react-native'
const { InterAppCommunication } = NativeModules


function remote(target, name, descriptor) {
  const originalFunction = descriptor.value;
  descriptor.value = function(uuid) {
    InterAppCommunication.sendJSFunctionResult(null, uuid, originalFunction.apply(this, arguments));
  }

  return descriptor;
}
export default remote;
