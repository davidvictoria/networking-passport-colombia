import React, { useEffect, useState } from 'react';
import { Box, Grid, Image, Text, VStack } from '@chakra-ui/react';
import axios from 'axios';
import BASE_API_URL from '../base-api.ts';
import Stamp from './Stamp.tsx';

interface PassportData {
  stamped_sponsors: string[];
}

interface PassportProps {
  shortId: string;
}

const Passport: React.FC<PassportProps> = ({ shortId }) => {
  const [passportData, setPassportData] = useState<PassportData | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Lista de todos los sponsors disponibles
  const allSponsors = ['1', '2', '3', '4', '5', '6', '7', '8', '9'];

  useEffect(() => {
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
      <Text fontSize="lg" fontWeight="bold" mb={4}>
        Pasaporte de Networking
      </Text>
      <Grid templateColumns="repeat(3, 1fr)" gap={4}>
        {allSponsors.map((sponsorId) => (
          <Box key={sponsorId} textAlign="center">
            <Stamp
              stampID={sponsorId}
              stampedIDs={passportData?.stamped_sponsors || []}
            />
            <Text fontSize="sm" mt={2}>
              Sponsor {sponsorId}
            </Text>
          </Box>
        ))}
      </Grid>
    </Box>
  );
};

export default Passport; 