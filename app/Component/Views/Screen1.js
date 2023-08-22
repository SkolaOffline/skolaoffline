import React, { useState } from 'react';
import { Text, StyleSheet } from 'react-native';
import { TouchableRipple } from 'react-native-paper';

const TextInANest = () => {
  const [titleText, setTitleText] = useState("Bird's Nest");
  const bodyText = 'This is not really a bird nest.';

  const onPressTitle = () => {
    setTitleText("Bird's Nest [pressed]");
  };

  return (
    <Text style={styles.baseText}>
      <TouchableRipple onPress={onPressTitle}>
        <Text style={styles.titleText}>
          {titleText}
          {'\n'}
          {'\n'}
        </Text>
      </TouchableRipple>
      <Text numberOfLines={5}>{bodyText}</Text>
    </Text>
  );
};

const styles = StyleSheet.create({
  baseText: {
    fontFamily: 'Cochin',
  },
  titleText: {
    fontSize: 20,
    fontWeight: 'bold',
  },
});

export default TextInANest;
