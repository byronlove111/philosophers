/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/06 12:16:00 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/08 21:42:49 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../include/philo.h"

/*
** @param argc Nombre d'arguments (5 ou 6)
** @param argv Arguments:
**             [1] number_of_philosophers
**             [2] time_to_die (ms)
**             [3] time_to_eat (ms)
**             [4] time_to_sleep (ms)
**             [5] number_of_times_each_philosopher_must_eat (optionnel)
**
** @return 0 si succes, 1 si erreur
*/
int	main(int argc, char **argv)
{
	t_data	data;
	int		res;

	res = parse_args(argc, argv, &data);
	if (res < 0)
		return (1);
	res = init_data(&data);
	if (res < 0)
		return (1);
	res = start_simulation(&data);
	cleanup(&data);
	if (res < 0)
		return (1);
	return (0);
}
