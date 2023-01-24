import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View } from 'react-native';
import { Provider as PaperProvider } from 'react-native-paper';
import * as React from 'react';
import { Button } from 'react-native-paper';


export default function App() {
  return (
    <View style={styles.container}>
        <Button icon="camera" mode="contained" onPress={() => console.log('Hi mom')}>
    Press me
  </Button>
      <StatusBar style="auto" />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});
