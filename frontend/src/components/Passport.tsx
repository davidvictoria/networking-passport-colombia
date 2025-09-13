import React, { useEffect, useState, useRef } from 'react';
import { Box, Grid, Text } from '@chakra-ui/react';
import axios from 'axios';
import BASE_API_URL from '../base-api.ts';
import Stamp from './Stamp.tsx';

interface PassportData {
  stamped_sponsors: string[];
}

interface PassportProps {
  shortId: string;
}

// Mapeo de IDs a nombres de sponsors
const sponsorNames: Record<string, string> = {
  '1': 'AWS Community Builders',
  '2': 'AWS User Groups',
  '3': 'AWS Heroes',
};

const Passport: React.FC<PassportProps> = ({ shortId }) => {
  const [passportData, setPassportData] = useState<PassportData | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const fetchedRef = useRef(false);

  // Lista de todos los sponsors disponibles
  const allSponsors = ['1', '2', '3'];

  useEffect(() => {
    if (fetchedRef.current) return;
    fetchedRef.current = true;

    const fetchPassportData = async () => {
      try {
        const response = await axios.get<PassportData>(
          `${BASE_API_URL}/attendee/passport?short_id=${shortId}`
        );
        setPassportData(response.data);
      } catch (error) {
        console.error('Error fetching passport data:', error);
        // Si hay error, asumimos que no hay sellos
        setPassportData({ stamped_sponsors: [] });
      } finally {
        setIsLoading(false);
      }
    };

    if (shortId) {
      fetchPassportData();
    }
  }, [shortId]);

  if (isLoading) {
    return <Text>Cargando pasaporte...</Text>;
  }

  return (
    <Box>
      <Text fontSize="lg" fontWeight="bold" mb={1}>
        Pasaporte Digital
      </Text>
      <Text fontSize="sm" fontStyle="italic" mb={3} mt={0}>
        ¡Llevas {passportData?.stamped_sponsors.length || 0} de 3 sellos!
      </Text>
      <Grid templateColumns="repeat(3, 1fr)" gap={4}>
        {allSponsors.map((sponsorId) => (
          <Box key={sponsorId} textAlign="center">
            <Stamp
              stampID={sponsorId}
              stampedIDs={passportData?.stamped_sponsors || []}
            />
            <Text fontSize="sm" mt={2}>
              {sponsorNames[sponsorId] || `Patrocinador ${sponsorId}`}
            </Text>
          </Box>
        ))}
      </Grid>
    </Box>
  );
};

export default Passport; 