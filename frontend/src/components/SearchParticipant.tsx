import React, {useEffect, useRef, useState} from 'react';
import {
    Box,
    Button,
    Container,
    FormControl,
    FormLabel,
    Heading,
    Input,
    Text,
    useToast,
    VStack,
    Alert,
    AlertIcon,
    Textarea,
    Grid
} from '@chakra-ui/react';
import {useLocation, useNavigate} from 'react-router-dom';
import axios from 'axios';
import BASE_API_URL from "../base-api.ts";
import NavBar from "./NavBar.tsx";

interface ParticipantData {
    first_name: string;
    last_name: string;
    role: string;
    company: string;
}

interface StampResponse {
    message: string;
    last_visit?: string;
    previous_notes?: string;
    visit_count?: number;
}

const SearchParticipant: React.FC = () => {
    const [eventCode, setEventCode] = useState<string>('');
    const [participantData, setParticipantData] = useState<ParticipantData | null>(null);
    const [isLoading, setIsLoading] = useState<boolean>(false);
    const [visitInfo, setVisitInfo] = useState<{message: string, last_visit?: string, previous_notes?: string, visit_count?: number} | null>(null);
    const [notes, setNotes] = useState<string>('');
    const [visitRegistered, setVisitRegistered] = useState<boolean>(false);
    const navigate = useNavigate();
    const location = useLocation();
    const toast = useToast();
    const visitRegisteredRef = useRef(false);

    const fetchParticipantData = async (code: string) => {
        const token = localStorage.getItem('sponsorToken');
        if (!token) {
            navigate('/sponsor-login');
            return;
        }

        setIsLoading(true);
        try {
            const response = await axios.get<ParticipantData>(
                `${BASE_API_URL}/sponsor/passport?short_id=${code.toUpperCase()}&jwt=${token}`
            );
            setParticipantData(response.data);
        } catch {
            toast({
                title: 'Error',
                description: 'Error al obtener datos del participante',
                status: 'error',
                duration: 3000,
                isClosable: true,
            });
        } finally {
            setIsLoading(false);
        }
    };

    useEffect(() => {
        const token = localStorage.getItem('sponsorToken');
        if (!token) {
            navigate('/sponsor-login');
            return;
        }

        const params = new URLSearchParams(location.search);
        const shortId = params.get('short_id');
        if (shortId && !visitRegisteredRef.current) {
            setEventCode(shortId);
            handleRegisterVisit(token, shortId);
            visitRegisteredRef.current = true;
        }
    }, [location]);


    const handleSearch = () => {
        setParticipantData(null);
        navigate(`/search-participant?short_id=${eventCode}`);
    };

    const handleRegisterVisit = async (token: string, eventCode: string, includeNotes: boolean = false, onlyUpdateComments: boolean = false) => {
        if (!token) {
            navigate('/sponsor-login');
            return;
        }

        setIsLoading(true);
        setVisitInfo(null);
        try {
            const requestData: any = {
                short_id: eventCode,
                jwt: token,
            };
            
            if (includeNotes) {
                requestData.notes = notes.trim() || undefined;
            }
            
            if (onlyUpdateComments) {
                requestData.register_visit = false;
            }
            
            const response = await axios.post<StampResponse>(
                `${BASE_API_URL}/sponsor/passport`,
                requestData
            );
            
            const { message, visit_count, last_visit, previous_notes } = response.data;
            
            if (message === "Visit updated") {
                toast({
                    title: `Visita #${visit_count} registrada`,
                    description: `Total de visitas: ${visit_count}`,
                    status: 'success',
                    duration: 3000,
                    isClosable: true,
                });
                setVisitRegistered(true);
                
                if (previous_notes) {
                    setNotes(previous_notes);
                }
            } else if (message === "First visit registered") {
                toast({
                    title: 'Primera visita registrada',
                    description: 'Participante registrado exitosamente',
                    status: 'success',
                    duration: 3000,
                    isClosable: true,
                });
                setVisitRegistered(true);
            }
            
            setVisitInfo({
                message,
                visit_count,
                last_visit,
                previous_notes
            });
            
            fetchParticipantData(eventCode);
        } catch (error: any) {
            toast({
                title: 'Error',
                description: 'Error al registrar la visita',
                status: 'error',
                duration: 3000,
                isClosable: true,
            });
        } finally {
            setIsLoading(false);
        }
    };

    const handleUpdateNotes = async () => {
        const token = localStorage.getItem('sponsorToken');
        if (token && eventCode) {
            await handleRegisterVisit(token, eventCode, true, true);
        }
    };

    return (
        <>
            <NavBar/>
            <Container mt={6}>
                <Heading>
                    Buscar Participante
                </Heading>
                <Box maxWidth="600px" margin="auto" mt={8}>
                    <VStack spacing={4} align="stretch">
                        <FormControl>
                            <FormLabel>
                                Código del Participante
                                <Text fontSize='xs' color="gray">Puedes encontrar el código del participante debajo del código QR.</Text>
                            </FormLabel>
                            <Input
                                value={eventCode}
                                onChange={(e) => setEventCode(e.target.value)}
                                placeholder="Ingresa el código del participante"
                            />
                        </FormControl>
                        <Button onClick={handleSearch} isLoading={isLoading}>
                            Buscar
                        </Button>

                        {participantData && (
                            <>
                                <Box>
                                    <Text fontSize="xl" fontWeight="bold">
                                        {participantData.first_name} {participantData.last_name}
                                    </Text>
                                    <Text>
                                        {participantData.role}
                                    </Text>
                                    <Text><b>{participantData.company}</b></Text>
                                    {visitInfo?.visit_count && (
                                        <Text fontSize="sm" color="blue.600" mt={1}>
                                            Visitas a este stand: {visitInfo.visit_count}
                                        </Text>
                                    )}
                                </Box>
                                
                                {!visitRegistered && (
                                    <Button 
                                        colorScheme="blue" 
                                        onClick={() => handleRegisterVisit(localStorage.getItem('sponsorToken') || '', eventCode)}
                                        isLoading={isLoading}
                                        isDisabled={!eventCode}
                                    >
                                        Registrar visita
                                    </Button>
                                )}
                                
                                <FormControl>
                                    <FormLabel>
                                        Comentarios adicionales (opcional)
                                        <Text fontSize='xs' color="gray">
                                            Puedes agregar o actualizar notas sobre la visita del participante
                                        </Text>
                                    </FormLabel>
                                    <Textarea
                                        value={notes}
                                        onChange={(e) => setNotes(e.target.value)}
                                        placeholder="Escribe comentarios sobre la visita..."
                                        rows={3}
                                        resize="vertical"
                                    />
                                </FormControl>
                                
                                <Box>
                                    <Text fontSize="sm" fontWeight="medium" mb={2}>
                                        Opciones rápidas:
                                    </Text>
                                    <Grid templateColumns="repeat(2, 1fr)" gap={2}>
                                        <Button
                                            size="sm"
                                            variant="outline"
                                            onClick={() => setNotes("Interesado en posiciones Sr.")}
                                        >
                                            Interesado en posiciones Sr.
                                        </Button>
                                        <Button
                                            size="sm"
                                            variant="outline"
                                            onClick={() => setNotes("Buscando internship/pasantía")}
                                        >
                                            Buscando internship/pasantía
                                        </Button>
                                        <Button
                                            size="sm"
                                            variant="outline"
                                            onClick={() => setNotes("Perfil técnico fuerte")}
                                        >
                                            Perfil técnico fuerte
                                        </Button>
                                        <Button
                                            size="sm"
                                            variant="outline"
                                            onClick={() => setNotes("Buscando partnership/colaboración")}
                                        >
                                            Buscando partnership/colaboración
                                        </Button>
                                        <Button
                                            size="sm"
                                            variant="outline"
                                            onClick={() => setNotes("Seguir en contacto")}
                                        >
                                            Seguir en contacto
                                        </Button>
                                        <Button
                                            size="sm"
                                            variant="outline"
                                            onClick={() => setNotes("Interesado en nuestros servicios")}
                                        >
                                            Interesado en nuestros servicios
                                        </Button>
                                    </Grid>
                                </Box>
                                
                                {visitRegistered && (
                                    <Button 
                                        colorScheme="green" 
                                        onClick={handleUpdateNotes}
                                        isLoading={isLoading}
                                        isDisabled={!notes.trim()}
                                    >
                                        {visitInfo?.previous_notes ? 'Actualizar comentarios' : 'Guardar comentarios'}
                                    </Button>
                                )}
                                
                                {visitInfo?.last_visit && (
                                    <Alert status="info">
                                        <AlertIcon />
                                        <Box>
                                            <Text fontWeight="bold">Última visita</Text>
                                            <Text fontSize="sm">
                                                {new Date(visitInfo.last_visit).toLocaleString('es-ES')}
                                            </Text>
                                        </Box>
                                    </Alert>
                                )}
                            </>
                        )}
                    </VStack>
                </Box>
            </Container>
        </>
    );
};

export default SearchParticipant;