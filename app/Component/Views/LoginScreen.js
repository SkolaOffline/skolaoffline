import React, { useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { Provider as PaperProvider, TextInput, Button, Snackbar } from 'react-native-paper';


import {APIHandler} from '../Shared/APIHandler';
import { router } from 'expo-router';

export default function LoginScreen() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [invalidVisible, setInvalidVisible] = useState(false); // State to control visibility of the Snackbar
  const [loginError, setLoginError] = useState('None');


  const login_handler = ({navigation}) => {
    APIHandler.Authenticate(username,password)
    .catch(error => {
            showSnackbar(error.message);
            console.error(error.message)
    });
    router.navigate("/Component/Views/Screen1");
  }

  // Function to show the Snackbar
  function showSnackbar(error){
    setLoginError(error)
    setInvalidVisible(true);

    // Automatically hide the Snackbar after 3000 milliseconds (3 seconds)
    setTimeout(() => {
      hideSnackbar();
    }, 4000);
  };

  // Function to hide the Snackbar
  const hideSnackbar = () => {
    setInvalidVisible(false);
  };



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
        <Snackbar
        visible={invalidVisible}
        onDismiss={hideSnackbar}
        action={{
          label: 'OK',
          onPress: hideSnackbar,
        }}
      >
      {loginError}
      </Snackbar>
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
