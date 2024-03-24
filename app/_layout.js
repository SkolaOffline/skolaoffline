import { Stack } from 'expo-router';

export const unstable_settings = {
  // Ensure any route can link back to `/`
  initialRouteName: 'index',
  home:{
    initialRouteName: 'home',
  }
};

export default function Layout() {
  return (
  <Stack>
    <Stack.Screen name='login' options={{headerShown: false}} />
    <Stack.Screen name='index' options={{headerShown: false}} />
    <Stack.Screen name='(home)' options={{headerShown: false}} />
  </Stack>
    )
}
