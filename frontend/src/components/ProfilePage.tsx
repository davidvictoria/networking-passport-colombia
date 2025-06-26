import React, { useState, useEffect } from 'react';
import {
    Box,
    Button,
    Container,
    Divider,
    Heading,
    Input,
    Modal,
    ModalBody,
    ModalContent,
    ModalFooter,
    ModalHeader,
    ModalOverlay,
    Text,
    useColorModeValue,
    useToast,
    VStack
} from '@chakra-ui/react';
import {DownloadIcon, GlobeIcon, LinkedinIcon, Mail, X as CloseIcon} from 'lucide-react';
import axios from 'axios';
import ProfileItem from "./ProfileItem.tsx";
import BASE_API_URL from "../base-api.ts";
import NavBar from "./NavBar.tsx";
import Cookies from 'js-cookie';
import {useNavigate} from "react-router-dom";
import {ValidationResponse} from "../types/validation.ts";
import {Profile} from "../types/profile.ts";
import Passport from "./Passport.tsx";


const ProfilePage: React.FC = () => {
    const [profile, setProfile] = useState<Profile | null>(null);
    const [isLoading, setIsLoading] = useState(true);
    const [pin, setPin] = useState('');
    const [isPinModalOpen, setIsPinModalOpen] = useState(false);
    const [showInactiveModal, setShowInactiveModal] = useState(false);
    const [isInitialized, setIsInitialized] = useState<boolean | null>(null);
    const [activationMethod, setActivationMethod] = useState<'both' | 'email'>('both');
    const [activationValue, setActivationValue] = useState('');

    const toast = useToast();
    const bgColor = useColorModeValue('gray.50', 'gray.800');
    const cardBgColor = useColorModeValue('white', 'gray.700');

    const urlParams = new URLSearchParams(window.location.search);
    const initialShortId = urlParams.get('short_id') || '';
    const [shortID] = useState(initialShortId);

    const navigate = useNavigate();


    const fetchProfile = async () => {
        const visitorId = Cookies.get('visitorId');
        setIsLoading(true);
        try {
            if (isInitialized === false) {
                setIsLoading(false);
                return;
            }
            const response = await axios.get<Profile>(`${BASE_API_URL}/attendee?short_id=${shortID}&pin=${pin}&device=${visitorId}`);
            setProfile(response.data);
            setIsPinModalOpen(false);
        } catch {
            toast({
                title: 'Error',
                description: 'No se pudo encontrar el perfil con el PIN proporcionado.',
                status: 'error',
                duration: 3000,
                isClosable: true,
            });
        } finally {
            setIsLoading(false);
        }
    };


    const handlePinSubmit = () => {
        if (pin.length === 4) {
            fetchProfile();
        } else {
            toast({
                title: 'Invalid PIN',
                description: 'Please enter a 4-digit PIN.',
                status: 'error',
                duration: 3000,
                isClosable: true,
            });
        }
    };

    const downloadVCF = () => {
        if (profile?.vcard) {
            const blob = new Blob([profile.vcard], {type: 'text/vcard'});
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `${profile.first_name}_${profile.last_name}.vcf`;
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }
    };

    useEffect(() => {
        const fetchValidation = async () => {
            try {
                const response = await axios.get<ValidationResponse>(`${BASE_API_URL}/attendee/validate?short_id=${shortID}`);
                setIsInitialized(response.data.initialized);
                setActivationMethod(response.data.method);
                if (!response.data.initialized) {
                    setShowInactiveModal(true);
                } else {
                    setIsPinModalOpen(true);
                }
            } catch {
                setIsInitialized(null);
            }
        };
        if (shortID) fetchValidation();
    }, [shortID, navigate]);

    return (
        <>
            <NavBar/>
            <Box bg={bgColor} minHeight="100vh">
                <Container maxW="container.md" py={10}>
                    <VStack
                        spacing={6}
                        align="stretch"
                        bg={cardBgColor}
                        p={8}
                        borderRadius="lg"
                        boxShadow="xl"
                    >
                        {profile ? (
                            <>
                                <VStack>
                                    <Heading size="xl"
                                             textAlign="center">{`${profile.first_name} ${profile.last_name}`}</Heading>
                                    <Text fontSize="lg" color="gray.500" textAlign="center">{profile.role}</Text>
                                    <Text fontSize="lg" color="gray.500" textAlign="center">{profile.company}</Text>
                                </VStack>
                                <Divider/>
                                <VStack align="stretch" spacing={4}>
                                    {profile.email && (
                                        <ProfileItem icon={Mail} label="Email" value={profile.email}
                                                     isLoading={isLoading}/>
                                    )}
                                    {profile.phone && (
                                        <ProfileItem icon={Mail} label="Teléfono" value={profile.phone}
                                                     isLoading={isLoading}/>
                                    )}
                                    {profile.social_links
                                        .filter(link => link.url !== "")
                                        .map((link, index) => (
                                            <ProfileItem
                                                key={index}
                                                icon={link.name === 'LinkedIn' ? LinkedinIcon : GlobeIcon}
                                                label={link.name}
                                                value={link.url}
                                                isLoading={isLoading}
                                            />
                                        ))}
                                </VStack>
                                <Button
                                    leftIcon={<DownloadIcon/>}
                                    colorScheme="blue"
                                    onClick={downloadVCF}
                                    size="lg"
                                    mt={4}
                                    style={{
                                        whiteSpace: "normal",
                                        wordWrap: "break-word",
                                    }}
                                >
                                    Descargar tarjeta de contacto
                                </Button>
                                <Divider/>
                                {profile && shortID && <Passport shortId={shortID} />}
                            </>
                        ) : (
                            <>
                                <Text textAlign="center" mb={4}>
                                    Este perfil aún no ha sido activado, pero puedes ver el estado de su pasaporte.
                                </Text>
                                {shortID && <Passport shortId={shortID} />}
                            </>
                        )}
                    </VStack>
                </Container>

                {/* Modal para perfil no activado */}
                <Modal isOpen={showInactiveModal && isInitialized === false} onClose={() => setShowInactiveModal(false)}>
                    <ModalOverlay/>
                    <ModalContent>
                        <ModalHeader display="flex" alignItems="center" justifyContent="space-between">
                            Perfil no activado
                            <Button variant="ghost" size="sm" onClick={() => setShowInactiveModal(false)} aria-label="Cerrar" p={0} minW={6}>
                                <CloseIcon size={20}/>
                            </Button>
                        </ModalHeader>
                        <ModalBody>
                            <Text mb={4}>Para poder compartir tus datos y acceder a todas las funcionalidades, primero debes activar tu perfil.</Text>
                            <Button colorScheme="blue" w="100%" onClick={() => navigate(`/activate?short_id=${shortID}&method=${activationMethod}`)}>
                                Activar mi perfil
                            </Button>
                        </ModalBody>
                    </ModalContent>
                </Modal>

                {/* Modal de PIN */}
                <Modal isOpen={isPinModalOpen && isInitialized === true} onClose={() => setIsPinModalOpen(false)}>
                    <ModalOverlay/>
                    <ModalContent>
                        <ModalHeader display="flex" alignItems="center" justifyContent="space-between">
                            Ingresa el PIN
                            <Button variant="ghost" size="sm" onClick={() => setIsPinModalOpen(false)} aria-label="Cerrar" p={0} minW={6}>
                                <CloseIcon size={20}/>
                            </Button>
                        </ModalHeader>
                        <ModalBody>
                            <Input
                                type="number"
                                placeholder="Ingresa el PIN de 4 dígitos"
                                value={pin}
                                onChange={(e) => setPin(e.target.value)}
                                maxLength={4}
                            />
                        </ModalBody>
                        <ModalFooter>
                            <Button colorScheme="blue" onClick={handlePinSubmit}>
                                Enviar
                            </Button>
                        </ModalFooter>
                    </ModalContent>
                </Modal>
            </Box>
        </>
    );
};

export default ProfilePage;