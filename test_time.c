/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   test_time.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: abbouras <abbouras@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/11/06 12:41:00 by abbouras          #+#    #+#             */
/*   Updated: 2025/11/06 13:01:25 by abbouras         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "include/philo.h"

void	test_get_time(void)
{
	long	time1;
	long	time2;

	printf("=== Test get_time() ===\n");
	time1 = get_time();
	usleep(100000);
	time2 = get_time();
	printf("Time1: %ld ms\n", time1);
	printf("Time2: %ld ms\n", time2);
	printf("Difference: %ld ms (should be ~100ms)\n\n", time2 - time1);
}

void	test_elapsed_time(void)
{
	long	start;
	long	elapsed;

	printf("=== Test get_elapsed_time() ===\n");
	start = get_time();
	usleep(50000);
	elapsed = get_elapsed_time(start);
	printf("Elapsed: %ld ms (should be ~50ms)\n\n", elapsed);
}

void	test_ft_usleep(void)
{
	long	start;
	long	end;
	long	actual;
	int		tests[] = {10, 50, 100, 200, 500};
	int		i;

	printf("=== Test ft_usleep() ===\n");
	i = 0;
	while (i < 5)
	{
		start = get_time();
		ft_usleep(tests[i]);
		end = get_time();
		actual = end - start;
		printf("ft_usleep(%d ms) → actual: %ld ms → ", tests[i], actual);
		if (actual >= tests[i] && actual <= tests[i] + 10)
			printf("✓ OK\n");
		else
			printf("✗ FAIL (drift: %ld ms)\n", actual - tests[i]);
		i++;
	}
	printf("\n");
}

void	test_precision(void)
{
	long	start;
	long	end;
	int		i;
	long	total;
	long	avg;

	printf("=== Test de precision (100 iterations de 100ms) ===\n");
	i = 0;
	total = 0;
	while (i < 100)
	{
		start = get_time();
		ft_usleep(100);
		end = get_time();
		total += (end - start);
		i++;
	}
	avg = total / 100;
	printf("Moyenne: %ld ms (should be ~100ms)\n", avg);
	printf("Drift moyen: %ld ms\n\n", avg - 100);
}

int	main(void)
{
	printf("========================================\n");
	printf("  TESTS DES FONCTIONS DE TEMPS\n");
	printf("========================================\n\n");
	test_get_time();
	test_elapsed_time();
	test_ft_usleep();
	test_precision();
	printf("========================================\n");
	printf("  FIN DES TESTS\n");
	printf("========================================\n");
	return (0);
}

