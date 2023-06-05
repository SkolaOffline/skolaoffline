import React, { useState } from 'react';
import { StyleSheet, View } from 'react-native';
import { BottomNavigation, BottomNavigationTab } from 'react-native-paper';

import Screen1 from '../Views/Screen1';
import Screen2 from '../Views/Screen2';
import Screen3 from '../Views/Screen3';
import Screen4 from '../Views/Screen4';
import Screen5 from '../Views/Screen5';

export default function LoginScreen({ navigation }) {
  const [index, setIndex] = useState(0);

  const routes = [
    { key: 'screen1', title: 'Screen 1', icon: 'home' },
    { key: 'screen2', title: 'Screen 2', icon: 'account' },
    { key: 'screen3', title: 'Screen 3', icon: 'email' },
    { key: 'screen4', title: 'Screen 4', icon: 'star' },
    { key: 'screen5', title: 'Screen 5', icon: 'settings' },
  ];

  const renderScene = BottomNavigation.SceneMap({
    screen1: Screen1,
    screen2: Screen2,
    screen3: Screen3,
    screen4: Screen4,
    screen5: Screen5,
  });

  return (
    <View style={styles.container}>
      {renderScene({ route: routes[index] })}
      <BottomNavigation
        navigationState={{ index, routes }}
        onIndexChange={setIndex}
        renderScene={renderScene}
        renderLabel={({ route }) => <BottomNavigationTab label={route.title} icon={route.icon} />}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
