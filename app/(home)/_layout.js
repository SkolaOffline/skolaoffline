import React from 'react';
import FontAwesome from '@expo/vector-icons/FontAwesome';
import { Tabs } from 'expo-router';

export const unstable_settings = {
    initialRouteName: '(home)/home',
};

export default function TabLayout() {
return (
    <Tabs screenOptions={{ tabBarActiveTintColor: 'blue' }}>
    <Tabs.Screen
        name="home"
        options={{
        title: 'Home',
        tabBarIcon: ({ color }) => <FontAwesome size={28} name="home" color={color} />,
        }}
    />
    <Tabs.Screen
        name="settings"
        options={{
        title: 'Settings',
        tabBarIcon: ({ color }) => <FontAwesome size={28} name="cog" color={color} />,
        }}
    />
    </Tabs>
);
}
