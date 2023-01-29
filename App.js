import React from 'react';
import { View, Text } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { loginScreen} from './app/Component/Views/LoginScreen'

const Stack = createNativeStackNavigator();


function App() {

  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Login" component={loginScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default App;