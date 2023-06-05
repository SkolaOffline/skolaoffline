import React, { useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { Provider as PaperProvider, TextInput, Button } from 'react-native-paper';
import base64 from 'base-64';

export default function LoginScreen() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = () => {
    console.log('Username:', username);
    console.log('Password:', password);
    let responseData; // Declare a variable in a higher scope

    fetch('https://aplikace.skolaonline.cz/SOLWebApi/api/v1/AuthorizationStatus', {
      method: 'GET',
      headers: {
        'Authorization': 'Basic ' + base64.encode(username + ':' + password)
      }
    })
    .then(response => response.json())
    .then(data => {
      responseData = data; // Assign the data object to the variable
      console.log(responseData); // Output: the data object
    })
    .catch(error => console.error(error));
    
 
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
        <Button style={[styles.input, { marginTop: 16 }]} mode="contained" onPress={handleLogin}>
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
