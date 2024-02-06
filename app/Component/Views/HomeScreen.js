import React, { useState } from 'react';
import { View } from 'react-native';
import { BottomNavigation, Text } from 'react-native-paper';


import Screen1 from './Screen1.js';
import Screen2 from './Screen2.js';
import Screen3 from './Screen3.js';
import Screen4 from './Screen4.js';
import Screen5 from './Screen5.js';



export default function HomeScreen() {
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
      { <BottomNavigation
        index={index}
        routes={routes}
        onIndexChange={setIndex}
        renderScene={renderScene}
        renderLabel={({ route }) => <BottomNavigationTab label={route.title} icon={route.icon} />}
      />  
      }
      </View>
  );
}

const styles = {
  container: {
    flex: 1,
  },
};
