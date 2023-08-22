import React, { useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { Provider as PaperProvider, TextInput, Button } from 'react-native-paper';

import {APIHandler} from '../Shared/APIHandler';

export default function LoginScreen() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const login_handler = () => {
    APIHandler.loginUser(username,password);
  }


  return (
    <PaperProvider>
      <View style={styles.container}>
        <TextInput 
          style={styles.input}
          label="Username"
          
          onChangeText={text => setUsername(text)}
        />
        <TextInput 
          style={[styles.input, { marginTop: 16 }]}
          label="Password"
          value={password}
          onChangeText={text => setPassword(text)}
          secureTextEntry
        />
        <Button style={[styles.input, { marginTop: 16 }]} mode="contained" onPress={login_handler}>
          Login
        </Button>
      </View>
    </PaperProvider>
  );
}


const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 16,
    paddingHorizontal: 16,
  },
  input: {
    width: 300,
    borderWidth: 1,
    borderColor: '#ccc',
    paddingHorizontal: 16,
  },
});
