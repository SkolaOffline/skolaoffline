
import { Button, TextInput } from 'react-native-paper';
import { Text, View } from 'react-native';




export function loginScreen(){
    
    return (
        <View>
            <TextInput label="Username" left={<TextInput.Icon name="account" />} />
            <TextInput
             label="Password"
             secureTextEntry
              left={<TextInput.Icon name="form-textbox-password" />}
             />

            <Button>Přihlásit</Button>
        </View>
        )
}