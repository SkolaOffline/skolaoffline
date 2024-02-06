
import React, { useState, useEffect } from 'react';
import { View, Text, ActivityIndicator } from 'react-native';

const LoadingScreen = () => {
    return (
        <View style={styles.container}>
            <ActivityIndicator size="large" color="#0000ff" />
            <Text style={styles.loadingText}>Loading...</Text>
        </View>
    );
};

const App = () => {
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        // Simulating an asynchronous task
        setTimeout(() => {
            setIsLoading(false);
        }, 3000);
    }, []);

    return (
        <View style={styles.container}>
            {isLoading ? <LoadingScreen /> : <Text>Content loaded!</Text>}
        </View>
    );
};

const styles = {
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#f1f1f1',
    },
    loadingText: {
        fontSize: 24,
        fontWeight: 'bold',
    },
};

export default App;