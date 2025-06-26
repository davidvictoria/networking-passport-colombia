import React, {useEffect, useState} from 'react';
import {Box, Button, Flex, Image} from '@chakra-ui/react';
import {useNavigate} from 'react-router-dom';

const Navbar: React.FC = () => {
    const [isLoggedIn, setIsLoggedIn] = useState<boolean>(false);
    const navigate = useNavigate();

    useEffect(() => {
        const checkLoginStatus = () => {
            const token = localStorage.getItem('sponsorToken');
            setIsLoggedIn(!!token);
        };

        checkLoginStatus();
        window.addEventListener('storage', checkLoginStatus);

        return () => {
            window.removeEventListener('storage', checkLoginStatus);
        };
    }, []);

    const handleLogout = () => {
        localStorage.removeItem('sponsorToken');
        setIsLoggedIn(false);
        navigate('/sponsor-login');
    };

    return (
        <Box position="sticky" top="0" zIndex="sticky">
            <Box bg="gray.700" px={4}>
                <Flex h={16} alignItems={'center'} justifyContent={'center'} position="relative">
                    <Image
                        src={"https://www.awscommunitydaycolombia.com/assets/images/png/logo.png"}
                        alt={"logo"}
                        height={45}
                        mx="auto"
                    />
                    {isLoggedIn && (
                        <Button colorScheme="red" onClick={handleLogout} position="absolute" right={0} top={"50%"} transform="translateY(-50%)">
                            Log Out
                        </Button>
                    )}
                </Flex>
            </Box>
        </Box>
    );
};

export default Navbar;